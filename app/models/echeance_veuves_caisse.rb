class EcheanceVeuvesCaisse < ApplicationRecord
  # EcheanceVeuvesCaisse.new(annee: 2023, trimestre: 1).save

  include WorkflowActiverecord

  workflow_column :workflow_state

  workflow do
    state :creation, meta: { label: 'Création' } do
      event :liquider, transition_to: :liquide, meta: { label: 'Liquider', types_profils: [:gestionnaire_compte_allocataire], retour: false }
    end

    state :liquide, meta: { label: 'Liquidé' } do
      event :valider_liquidation, transition_to: :liquidation_valide, meta: { label: 'Valider liquidation', types_profils: [:chef_agence], retour: false }
      event :retour_creation, transition_to: :creation, meta: { label: 'Retourner', types_profils: [:chef_agence], retour: true }
    end

    state :liquidation_valide, meta: { label: 'Liquidation validé' } do
      event :valider_paiement, transition_to: :paiement_valide, meta: { label: 'Valider paiement', types_profils: [:comptable], retour: false }
      event :retour_liquidation, transition_to: :liquide, meta: { label: 'Retourner', types_profils: [:comptable], retour: true }
    end

    state :paiement_valide, meta: { label: 'Paiement validé' } do
      event :liquider, transition_to: :liquide, meta: { label: 'Liquider', types_profils: [:gestionnaire_compte_allocataire], retour: false }
    end

    on_transition do |from, to, triggering_event, *event_args|
      puts "#{from} -> #{to}"
      WorkflowHistory.create(
        dossier: self,
        from: from,
        to: to,
        user: event_args[0]
      )
    end
  end

  has_many :echeance_veuves_caisse_epouses
  has_many :echeance_veuves_caisse_enfants
  has_many :echeance_veuves_caisse_lot_liquidations
  has_many :allocation_familiales

  scope :en_attente_validation_ca, -> { where(workflow_state: [:liquide]) }
  scope :en_attente_validation_cp, -> { where(workflow_state: [:liquidation_valide]) }

  before_create :set_periodes
  after_create -> { generate_veuves; generate_enfants_veuves }

  def set_periodes
    self.periode_debut = Date.new(self.annee, (self.trimestre - 1) * 3 + 1, 1)
    self.periode_fin = self.periode_debut.end_of_quarter
  end

  def peut_etre_affiche?
    if self.creation? or self.paiement_valide?
      echeance_veuves_caisse_enfants.exists?(liquide: false, document_valide: true)
    else
      true
    end
  end

  def can_visualize?
    (self.creation? or self.paiement_valide?) and echeance_veuves_caisse_enfants.exists?(liquide: false, document_valide: true)
  end

  def generate_veuves
    puts "générations des lignes veuves"
    return if self.echeance_veuves_caisse_epouses.any?
    ActiveRecord::Base.connection.execute(<<~SQL)
      INSERT INTO echeance_veuves_caisse_epouses (
        echeance_veuves_caisse_id, 
        workflow_state,
        numero_affiliation,
        conjoint_id,
        prenom,
        nom,
        nin,
        nombre_enfants,
        nombre_total_enfants_eligibles,
        date_naissance,
        est_repris,
        admin_agence_id,
        dossier_prestation_id,
        created_at,
        updated_at
      )
      (
        select DISTINCT ON (cj.id)
          #{self.id},
          'creation',
          cj.numero_affiliation,
          cj.id,
          cj.prenom,
          cj.nom,
          cj.numero_piece,
          count(distinct e1.id) as nombre_enfants,
          count(distinct e.id) as nombre_total_enfants_eligibles,
          cj.date_naissance,
          cj.est_repris,
          dp.agence_id,
          dp.id,
          NOW(),
          NOW()
        from dossier_prestations dp 
          inner join enfants e on e.numero_affiliation = dp.num_affiliation
          left join enfants e1 on e1.numero_affiliation = dp.num_affiliation
          left join conjoints cj on cj.numero_affiliation = dp.num_affiliation
        where
          e.conjoint_id = cj.id and e1.conjoint_id = cj.id and cj.etat = 2 and e.date_deces is null and cj.date_deces is null and dp.etat = 'suspendu' and dp.deleted = false and dp.incomplete = false  and e.id in
          (select id from
          (select ROW_NUMBER() OVER (PARTITION BY numero_affiliation ORDER BY date_naissance) AS ordre, id from enfants e2
          WHERE e2.numero_affiliation = dp.num_affiliation and
          e2.date_debut_eligibilite_af <= '#{periode_fin.strftime('%Y-%m-%d')}' and (e2.date_fin_eligibilite_af is null or e2.date_fin_eligibilite_af >= '#{periode_debut.strftime('%Y-%m-%d')}')
          and e2.deleted = false and e2.incomplete = false
          order by numero_affiliation, date_naissance)  t 
          where t.ordre <= 6)
          group by cj.id, dp.agence_id, dp.id
      )
    SQL
  end

  def generate_enfants_veuves
    puts "générations des lignes enfants"
    return if self.echeance_veuves_caisse_enfants.any?
    (0..2).each { |mois|
      ActiveRecord::Base.connection.execute(<<~SQL)
        INSERT INTO echeance_veuves_caisse_enfants (
          echeance_veuves_caisse_id,
          dossier_prestation_id,
          echeance_veuves_caisse_epouse_id,
          mois,
          enfant_id,
          conjoint_id,
          numero_ordre,
          montant,
          created_at,
          updated_at
        )
        (
          select #{id}, d.dossier_prestation_id, d.id, #{mois + 1}, e.id, e.conjoint_id, e.ordre, 2600, now(), now()
          from echeance_veuves_caisse_epouses d
          inner join
          (
            select * from
            (select ROW_NUMBER() OVER (PARTITION BY numero_affiliation ORDER BY date_naissance) AS ordre, id, numero_affiliation, conjoint_id
            from enfants e2
            where e2.date_debut_eligibilite_af <= '#{(periode_debut + mois.months).end_of_month.strftime('%Y-%m-%d')}' and (e2.date_fin_eligibilite_af is null or e2.date_fin_eligibilite_af >= '#{(periode_debut + mois.months).strftime('%Y-%m-%d')}')
            and e2.deleted = false and e2.incomplete = false
            order by numero_affiliation, date_naissance) t 
            where t.ordre <= 6
          ) e on e.conjoint_id = d.conjoint_id
          where d.echeance_veuves_caisse_id = #{id}
        )
      SQL

      ActiveRecord::Base.connection.execute(<<~SQL)
        UPDATE echeance_veuves_caisse_enfants set document_valide = true
        WHERE echeance_veuves_caisse_id = #{id} AND mois = #{mois + 1} AND (
          enfant_id in (select id from enfants e where date_expiration_piece >= '#{(periode_debut + mois.months).strftime('%Y-%m-%d')}')
          OR enfant_id in (select id from enfants e where migrated_document_exp_date >= '#{(periode_debut + mois.months).strftime('%Y-%m-%d')}')
          OR enfant_id in (select documentable_id
                            from documents d inner join enfants e on e.id = d.documentable_id
                            where documentable_type = 'Enfant' and (
                                e.date_naissance + interval '14 years' < '#{(periode_debut + mois.months).strftime('%Y-%m-%d')}' and type_document in (36, 66, 67)
                                or e.date_naissance + interval '14 years' >= '#{(periode_debut + mois.months).strftime('%Y-%m-%d')}' and type_document in (19, 36)
                              ) and date_expiration >= '#{(periode_debut + mois.months).strftime('%Y-%m-%d')}')
        )
      SQL
    }
  end

  # @param [User] user
  def liquider(user)
    ActiveRecord::Base.transaction do
      user = User.current
      lot = echeance_veuves_caisse_lot_liquidations.create(
        echeance_veuves_caisse: self,
        liquide_par: user,
        date_liquidation: Date.today
      )
      ActiveRecord::Base.connection.execute(<<~SQL)
        INSERT INTO echeance_veuves_caisse_liquidations (
          echeance_veuves_caisse_enfant_id,
          echeance_veuves_caisse_lot_liquidation_id,
          created_at,
          updated_at
        )
        (
          select ece.id, #{lot.id}, now(), now() 
          from echeance_veuves_caisse_enfants ece
          inner join echeance_veuves_caisse_epouses ecp on ecp.id = ece.echeance_veuves_caisse_epouse_id
          inner join echeance_veuves_caisses ecd on ecd.id = ece.echeance_veuves_caisse_id
          where ece.document_valide = true and ece.liquide = false and ecp.admin_agence_id =  #{user.admin_agence.id} and ecd.id = #{self.id}
        )
      SQL
    end
    if self.motif_retour
      self.motif_retour = nil
      self.save!
    end
  end

  # @param [User] user
  def valider_liquidation(user)
    lot = echeance_veuves_caisse_lot_liquidations.find_by(liquide: false)
    if lot.nil?
      halt! 'Impossible de trouver le lot de liquidation à liquider'
      return
    end
    lot.valide_ca_par = user
    lot.date_validation_ca = Date.today
    lot.save!
    if self.motif_retour
      self.motif_retour = nil
      self.save!
    end
  end

  # @param [User] user
  def valider_paiement(user)
    lot = echeance_veuves_caisse_lot_liquidations.find_by(liquide: false)
    if lot.nil?
      halt! 'Impossible de trouver le lot de liquidation à liquider'
      return
    end

    liquidations = lot.echeance_veuves_caisse_liquidations
    conjoint_op_array = liquidations.map { |liquidation| liquidation }.group_by { |x| x.echeance_veuves_caisse_enfant.conjoint_id }

    ActiveRecord::Base.transaction do

      conjoint_op_array.each do |cj|
        conjoint = Conjoint.find(cj.first)
        next if conjoint.nil?
        dossier_pf = DossierPrestation.where(num_affiliation: conjoint.numero_affiliation, conjoint_id: nil, etat: 'suspendu').first
        op = OrdrePaiement.create(dossier: dossier_pf, numero_allocataire: conjoint.numero_affiliation, beneficiaire_id: conjoint.id, type_beneficiary: 1, echeance_veuves_caisse_lot_liquidation_id: lot.id)

        cj.last.each { |liquidation|
          liquidation.liquider(user, op, conjoint)
        }
      end
      lot.valide_comptable_par = user
      lot.date_validation_comptable = Date.today
      lot.liquide = true
      lot.save!
    end
  end

  # @param [User] user
  def retour_creation(user)
    lot = echeance_veuves_caisse_lot_liquidations.where(liquide: false).order(id: :asc).last
    return if lot.nil?
    if lot.echeance_veuves_caisse_liquidations.destroy_all
      lot.destroy
    end
  end

end
