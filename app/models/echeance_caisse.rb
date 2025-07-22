class EcheanceCaisse < ApplicationRecord
  # exemple : e = EcheanceCaisse.create(annee: 2023, trimestre: 1)
  include WorkflowActiverecord

  before_create :set_periodes
  has_many :echeance_caisse_employeurs
  has_many :echeance_caisse_dossiers
  has_many :echeance_caisse_enfants
  has_many :echeance_caisse_lot_liquidations
  has_many :carriere_dossier_prestations
  has_many :allocation_familiales
  has_many :historic_ech_exclusions

  validates :trimestre, uniqueness: { scope: :annee }

  # after_create -> { generate_employeurs; generate_dossiers; generate_enfants_dossiers; generate_bordereau_pdf }
  after_create -> { generate_employeurs; generate_dossiers; generate_enfants_dossiers }

  workflow_column :workflow_state

  workflow do
    state :creation, meta: { label: 'Création' } do
      event :diffuser, transition_to: :diffuse
    end

    state :diffuse, meta: { label: 'Diffusé' }
  end

  def diffuser
    puts 'diffusion'
  end

  def set_periodes
    self.periode_debut = Date.new(self.annee, (self.trimestre - 1) * 3 + 1, 1)
    self.periode_fin = self.periode_debut.end_of_quarter
  end

  def generate_employeurs
    puts "générations des lignes employeurs"
    return if self.echeance_caisse_employeurs.any?
    ActiveRecord::Base.connection.execute(<<~SQL)
      INSERT INTO echeance_caisse_employeurs (
        echeance_caisse_id,
        workflow_state,
        matric,
        raison_sociale,
        ipres_ancien_matric,
        css_ancien_matric,
        code_agence_css,
        code_agence_ipres,
        email_mandataire,
        telephone_mandataire,
        prenom_mandataire,
        nom_mandataire,
        created_at,
        updated_at
      )
      (
        select
          #{self.id},
          'creation',
          dp.employeur_actuel,
          pe.fhrsoc,
          pe.ancien_num_ipres,
          pe.ancien_num_css,
          pe.code_agence_css,
          pe.code_agence_ipres,
          am.email,
          am.telephone,
          am.prenom,
          am.nom,
          NOW(),
          NOW()
        from dossier_prestations dp 
          inner join enfants e on e.numero_affiliation = dp.num_affiliation
          left join psrm_employeurs pe on pe.fhnum = dp.employeur_actuel
          left join admin_mandataires am on am.numero_employeur = dp.employeur_actuel 
        where
          e.date_debut_eligibilite_af <= '#{periode_fin.strftime('%Y-%m-%d')}' and (e.date_fin_eligibilite_af is null or e.date_fin_eligibilite_af >= '#{periode_debut.strftime('%Y-%m-%d')}')
          and e.deleted = false and e.incomplete = false
          and dp.employeur_actuel is not null and dp.etat = 'valide' and dp.deleted = false and dp.incomplete = false
        group by dp.employeur_actuel, pe.fhrsoc, pe.ancien_num_ipres, pe.ancien_num_css, pe.code_agence_css, pe.code_agence_ipres, am.email, am.telephone, am.prenom, am.nom
        having count(distinct dp.id) >=5
      )
    SQL
  end

  def generate_dossiers
    puts "générations des lignes dossiers"
    return if self.echeance_caisse_dossiers.any?
    ActiveRecord::Base.connection.execute(<<~SQL)
      INSERT INTO echeance_caisse_dossiers (
        echeance_caisse_id,
        dossier_prestation_id,
        echeance_caisse_employeur_id,
        employeur_actuel,
        workflow_state,
        num_affiliation,
        nin,
        prenom,
        nom,
        date_naissance,
        nombre_enfants,
        nombre_total_enfants_eligibles,
        created_at,
        updated_at
      )
      (
        select #{id}, dp2.id, ece.id, dp2.employeur_actuel, 'creation', dp2.num_affiliation, dp2.nin, dp2.prenom, dp2.nom, dp2.date_naissance, count(distinct e3.id) as nombre_enfants, count(distinct e2.id) as nombre_enfants_eligibles, NOW(), NOW()
        from dossier_prestations dp2
        inner join echeance_caisse_employeurs ece on ece.matric = dp2.employeur_actuel and ece.echeance_caisse_id = #{id}
        left join enfants e2 on e2.numero_affiliation = dp2.num_affiliation
        left join enfants e3 on e3.numero_affiliation = dp2.num_affiliation
        where dp2.etat = 'valide' and dp2.conjoint_id is null  and dp2.deleted = false and dp2.incomplete = false
          and e2.date_debut_eligibilite_af <= '#{periode_fin.strftime('%Y-%m-%d')}' and (e2.date_fin_eligibilite_af is null or e2.date_fin_eligibilite_af >= '#{periode_debut.strftime('%Y-%m-%d')}')
          and e2.deleted = false and e2.incomplete = false
          and dp2.date_naissance + INTERVAL '60 years' >= '#{periode_debut.strftime('%Y-%m-%d')}'
        group by dp2.employeur_actuel, dp2.id, dp2.num_affiliation, dp2.nin, dp2.prenom, dp2.nom, ece.id, dp2.date_naissance
      )
    SQL
  end

  def generate_enfants_dossiers
    puts "générations des lignes enfants"
    return if self.echeance_caisse_enfants.any?
    (0..2).each { |mois|
      ActiveRecord::Base.connection.execute(<<~SQL)
        INSERT INTO echeance_caisse_enfants (
          echeance_caisse_id,
          dossier_prestation_id,
          echeance_caisse_dossier_id,
          mois,
          enfant_id,
          numero_ordre,
          montant,
          created_at,
          updated_at
        )
        (
          select #{id}, d.dossier_prestation_id, d.id, #{mois + 1}, e.id, e.ordre, 2600, now(), now()
          from echeance_caisse_dossiers d
          inner join
          (
            select * from
            (select ROW_NUMBER() OVER (PARTITION BY numero_affiliation ORDER BY date_naissance) AS ordre, id, numero_affiliation
            from enfants e2
            where e2.date_debut_eligibilite_af <= '#{(periode_debut + mois.months).end_of_month.strftime('%Y-%m-%d')}' and (e2.date_fin_eligibilite_af is null or e2.date_fin_eligibilite_af >= '#{(periode_debut + mois.months).strftime('%Y-%m-%d')}')
            and e2.deleted = false and e2.incomplete = false
            order by numero_affiliation, date_naissance) t 
          ) e on e.numero_affiliation = d.num_affiliation
          where d.echeance_caisse_id = #{id}
        )
      SQL

      ActiveRecord::Base.connection.execute(<<~SQL)
        UPDATE echeance_caisse_enfants set document_valide = true
        WHERE echeance_caisse_id = #{id} AND mois = #{mois+1} AND (
          enfant_id in ((select id from enfants e where date_expiration_piece >= '#{(periode_debut + mois.months).strftime('%Y-%m-%d')}'
                                                   or migrated_document_exp_date >= '#{(periode_debut + mois.months).strftime('%Y-%m-%d')}')
                                                   union
                                                   (select documentable_id
                            from documents d inner join enfants e on e.id = d.documentable_id
                            where documentable_type = 'Enfant' and (
                                e.date_naissance + interval '14 years' < '#{(periode_debut + mois.months).strftime('%Y-%m-%d')}' and type_document in (36, 66, 67)
                                or e.date_naissance + interval '14 years' >= '#{(periode_debut + mois.months).strftime('%Y-%m-%d')}' and type_document in (19, 36)
                              ) and date_expiration >= '#{(periode_debut + mois.months).strftime('%Y-%m-%d')}'))
        );
      SQL
    }
  end

  def generate_bordereau_pdf
    return unless ENV['BORDEREAU_CSS_PATH']

    puts "génération du bordereau pdf"

    employeurs = self.echeance_caisse_employeurs.select(:id)
    i = 0
    total = employeurs.size
    employeurs.each { |employeur|
      GenerateBordereauEmployeurJob.perform_later(ENV['BORDEREAU_CSS_PATH'], employeur.id)
      i += 1
      puts "#{i}/#{total}"
    }
    true
  end

  def generate_bordereau_pdf_without_queue
    return unless ENV['BORDEREAU_CSS_PATH']

    puts "génération du bordereau pdf"

    employeurs = self.echeance_caisse_employeurs
    i = 0
    total = employeurs.size
    employeurs.each { |employeur|
      employeur.generate_bordereau_pdf(ENV['BORDEREAU_CSS_PATH'])
      i += 1
      puts "#{i}/#{total}"
    }
    true
  end

  def bordereau_download_agence_link(code='XX')
    "/download_bordereau_css/#{annee}#{trimestre}/BORDEREAU_#{annee}#{trimestre}_#{code}.zip"
  end
end
