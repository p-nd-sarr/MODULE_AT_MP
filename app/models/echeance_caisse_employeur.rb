class EcheanceCaisseEmployeur < ApplicationRecord
  include WorkflowActiverecord

  belongs_to :echeance_caisse
  has_many :echeance_caisse_dossiers
  has_many :echeance_caisse_enfants, through: :echeance_caisse_dossiers
  has_many :echeance_caisse_liquidations
  has_many :echeance_caisse_lot_liquidations
  has_many :historic_ech_exclusions

  has_one_attached :bordereau_rempli
  validates :bordereau_rempli, content_type: { in: 'application/pdf', message: "n'est pas un PDF" }

  accepts_nested_attributes_for :echeance_caisse_dossiers, allow_destroy: false, update_only: true

  workflow_column :workflow_state

  workflow do
    state :creation, meta: { label: 'Création' } do
      event :valider_temps_presence, transition_to: :temps_presence_valide, meta: { label: 'Valider TPS', types_profils: [:gestionnaire_compte_allocataire], retour: false }
    end

    state :temps_presence_valide, meta: { label: 'Temps de présence valide' } do
      event :liquider, transition_to: :liquide, meta: { label: 'Liquider', types_profils: [:gestionnaire_compte_allocataire], retour: false } do
        halt! 'Aucun enfant disponible pour une liquidation !' unless can_liquidate?
      end
      event :retourner_creation, transition_to: :creation, meta: { label: 'Annuler Validation TPS', types_profils: [:gestionnaire_compte_allocataire], retour: true } do
        halt! 'Modification temps de présence impossible : OP déjà généré pour cet employeur !' unless can_go_back?
      end
    end

    state :liquide, meta: { label: 'Liquidé' } do
      event :valider_liquidation, transition_to: :liquidation_valide, meta: { label: 'Valider liquidation', types_profils: [:chef_agence], retour: false }
      event :retour_temps_presence_valide, transition_to: :temps_presence_valide, meta: { label: 'Annuler liquidation', types_profils: [:chef_agence], retour: true }
    end

    state :liquidation_valide, meta: { label: 'Liquidation validé' } do
      event :valider_paiement, transition_to: :paiement_valide, meta: { label: 'Valider paiement', types_profils: [:comptable], retour: false }
      event :retour_liquidation, transition_to: :liquide, meta: { label: 'Annuler validation', types_profils: [:comptable], retour: true }
    end

    state :paiement_valide, meta: { label: 'Paiement validé' } do
      event :liquider, transition_to: :liquide, meta: { label: 'Liquider', types_profils: [:gestionnaire_compte_allocataire], retour: false } do
        halt! 'Aucun enfant disponible pour une liquidation !' unless can_liquidate?
      end
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

  after_update :perform_actions_after_transition

  def can_liquidate?
    self.echeance_caisse_dossiers.each do |dossier|
      if dossier.echeance_caisse_enfants.where(liquide: false).includes(:enfant).where(document_valide: true, payable: true).length > 0
        return true
      end
    end
    false
  end

  def can_visualize?
    (self.temps_presence_valide? or self.paiement_valide?) and echeance_caisse_enfants.exists?(liquide: false, document_valide: true, payable: true)
  end

  def perform_actions_after_transition
    if current_state == 'temps_presence_valide'
      update(workflow_state: :paiement_valide) unless can_go_back?
    end
  end

  def can_go_back?
    self.echeance_caisse_lot_liquidations.each do |lot|
      if OrdrePaiement.exists?(dossier_id: lot.id, dossier_type: lot.class.name)
        return false
      end
      if lot.allocation_familiales.exists?(paiement: true)
        return false
      end
    end
    true
  end

  # @param [User] user
  def valider_temps_presence(user)
    echeance_caisse_dossiers.each do |dossier|
      (1..3).each do |m|
        if dossier.time_of_presence_under_limit?(m)
          dossier.is_retired_salary_for_month?(m) ? dossier.echeance_caisse_enfants.where(mois: m).update_all(payable: true) : dossier.echeance_caisse_enfants.where(mois: m).update_all(payable: false)
        else
          dossier.is_retired_salary?(m) ? dossier.echeance_caisse_enfants.where(mois: m).update_all(payable: false) : dossier.echeance_caisse_enfants.where(mois: m).update_all(payable: true)
        end
      end
    end
    self.temps_presence_valide = true
    self.save!
  end

  # @param [User] user
  def retourner_creation(user)
    self.echeance_caisse_lot_liquidations.each do |lot|
      lot.echeance_caisse_liquidations.destroy_all
      lot.carriere_dossier_prestations.destroy_all
      lot.allocation_familiales.destroy_all
      lot.destroy
    end
    self.temps_presence_valide = false
    self.save!
  end

  def peut_etre_affiche?(echeance)
    if self.temps_presence_valide? or self.paiement_valide?
      ech_enfants = EcheanceCaisseEnfant.joins(:echeance_caisse_dossier).where(echeance_caisse_dossiers: { echeance_caisse_employeur_id: self.id }).where(echeance_caisse_enfants: { echeance_caisse_id: echeance.id, liquide: false, document_valide: true, payable: true })
      ech_enfants.length > 0
    else
      true
    end
  end

  def set_enfants_not_payable_after_payment
    echeance_caisse_dossiers.each do |dossier|
      if EcheanceCaisseLiquidation.where(echeance_caisse_enfant_id: dossier.echeance_caisse_enfants.pluck(:id), liquide: true).length >= 18
        dossier.echeance_caisse_enfants.where(liquide: false).update_all(payable: false)
      end
    end
  end

  # @param [User] user
  def liquider(user)
    ActiveRecord::Base.transaction do
      return if EcheanceCaisseLotLiquidation.exists?(echeance_caisse_id: echeance_caisse_id, echeance_caisse_employeur_id: id, liquide: false)
      lot = echeance_caisse_lot_liquidations.create(
        echeance_caisse: echeance_caisse,
        liquide_par: user,
        date_liquidation: Date.today
      )
      return if lot.nil?
      ActiveRecord::Base.connection.execute(<<~SQL)
        INSERT INTO echeance_caisse_liquidations (
          echeance_caisse_employeur_id,
          echeance_caisse_enfant_id,
          echeance_caisse_lot_liquidation_id,
          created_at,
          updated_at
        )
        (
          select ecd.echeance_caisse_employeur_id, ece.id, #{lot.id}, now(), now() 
          from echeance_caisse_enfants ece
          inner join echeance_caisse_dossiers ecd on ecd.id = ece.echeance_caisse_dossier_id
          where ecd.echeance_caisse_employeur_id = #{self.id} and ece.document_valide = true and ece.liquide = false and ece.payable = true
          and
          (ece.mois = 1 and (ecd.date_naissance + INTERVAL '60 years' >= '#{(self.echeance_caisse.periode_debut).strftime('%Y-%m-%d')}') or
          ece.mois = 2 and (ecd.date_naissance + INTERVAL '60 years' >= '#{(self.echeance_caisse.periode_debut + 1.months).strftime('%Y-%m-%d')}') or
          ece.mois = 3 and (ecd.date_naissance + INTERVAL '60 years' >= '#{(self.echeance_caisse.periode_debut + 2.months).strftime('%Y-%m-%d')}'))          
          and
          (ece.mois = 1 and (ecd.absence_justifie_mois1 = true or temps_presence_mois1 >= 18 or (ecd.date_naissance + INTERVAL '60 years' >= '#{(self.echeance_caisse.periode_debut).strftime('%Y-%m-%d')}' and ecd.date_naissance + INTERVAL '60 years' < '#{(self.echeance_caisse.periode_debut + 1.months).strftime('%Y-%m-%d')}')) or
          ece.mois = 2 and (ecd.absence_justifie_mois2 = true or temps_presence_mois2 >= 18 or (ecd.date_naissance + INTERVAL '60 years' >= '#{(self.echeance_caisse.periode_debut + 1.months).strftime('%Y-%m-%d')}' and ecd.date_naissance + INTERVAL '60 years' < '#{(self.echeance_caisse.periode_debut + 2.months).strftime('%Y-%m-%d')}')) or
          ece.mois = 3 and (ecd.absence_justifie_mois3 = true or temps_presence_mois3 >= 18 or (ecd.date_naissance + INTERVAL '60 years' >= '#{(self.echeance_caisse.periode_debut + 2.months).strftime('%Y-%m-%d')}' and ecd.date_naissance + INTERVAL '60 years' < '#{(self.echeance_caisse.periode_debut + 3.months).strftime('%Y-%m-%d')}')))
          ORDER BY
          ece.numero_ordre
        )
      SQL
      lot.delete_excess_liquidations
      lot.generate_time_of_presence_and_allocations(user)
      #lot.generate_time_of_presence_for_dossiers_with_beneficiaries(user)
    end

    if self.motif_retour
      self.motif_retour = nil
      self.save!
    end
  end

  # @param [User] user
  def valider_liquidation(user)
    lot = echeance_caisse_lot_liquidations.find_by(liquide: false)
    if lot.nil?
      halt! 'Impossible de trouver le lot de liquidation à liquider'
      return
    end
    lot.valider_allocations_par_ca(user)
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
    lot = echeance_caisse_lot_liquidations.find_by(liquide: false)
    if lot.nil?
      halt! 'Impossible de trouver le lot de liquidation à liquider'
      return
    end
    lot.set_individual_payment

    ActiveRecord::Base.transaction do
      montant_total = echeance_caisse_enfants.where(id: lot.echeance_caisse_liquidations.pluck(:echeance_caisse_enfant_id), paiement_individuel: false).sum(:montant)
      montant_total_individel = echeance_caisse_enfants.where(id: lot.echeance_caisse_liquidations.pluck(:echeance_caisse_enfant_id), paiement_individuel: true).sum(:montant)
      if montant_total > 0
        op = OrdrePaiement.create(dossier: lot)
        return if ComptaTransaction.exists?(dossier: lot, statut: [:paye, :en_cours])
        compta_transaction = ComptaTransaction.create(
          dossier: lot,
          ordre_paiement: op,
          code_operation: 'PF_AF',
          code_classe_evenement: 'ECHEANCE',
          numero_allocataire: identifiant_mandataire || matric,
          nom: nom_mandataire || raison_sociale,
          prenom: prenom_mandataire || raison_sociale,
          id_reel_allocataire: matric,
          code_agence_liquidation: code_agence_css,
          mode_paiement: :cheque,
          date_debut_periode: echeance_caisse.periode_debut,
          date_fin_periode: echeance_caisse.periode_fin,
          montant: montant_total,
          code_devise: 'XOF',
          description: "Echeance CSS : #{echeance_caisse.annee}#{echeance_caisse.trimestre}",
          admin_agence: user.admin_agence,
          date_comptable: Date.today
        )
      end

      if montant_total_individel > 0
        children = echeance_caisse_enfants.where(id: lot.echeance_caisse_liquidations.pluck(:echeance_caisse_enfant_id), paiement_individuel: true)
        dossiers = DossierPrestation.where(id: children.pluck(:dossier_prestation_id).uniq)
        dossiers.each do |dossier|
          op_array = Array.new
          allocations = dossier.allocation_familiales.where(trimestre: echeance_caisse.trimestre, annee: echeance_caisse.annee, echeance_caisse_lot_liquidation_id: lot.id)
          conjoint_beneficiary_array = dossier.beneficiary_associations_to_dps.map { |beneficiary| beneficiary }.group_by { |x| [x.type_beneficiary, x.conjoint_id, x.attributaire_tierce_id] }
          all_beneficiaries = dossier.beneficiary_associations_to_dps.map { |beneficiary| beneficiary[:enfant_id] }
          enfants = allocations.pluck(:enfant_id)

          conjoint_beneficiary_array.each do |cb|
            if (enfants & cb.last.pluck(:enfant_id)).any?
              if OrdrePaiement.type_beneficiaries[cb.first[0]] == 1
                op_array << OrdrePaiement.create(dossier: dossier, numero_allocataire: dossier.num_affiliation, beneficiaire_id: cb.first[1], type_beneficiary: OrdrePaiement.type_beneficiaries[cb.first[0]], echeance_caisse_lot_liquidation_id: lot.id)
              elsif OrdrePaiement.type_beneficiaries[cb.first[0]] == 2
                op_array << OrdrePaiement.create(dossier: dossier, numero_allocataire: dossier.num_affiliation, beneficiaire_id: cb.first[2], type_beneficiary: OrdrePaiement.type_beneficiaries[cb.first[0]], echeance_caisse_lot_liquidation_id: lot.id)
              end
            end
          end

          if enfants.difference(all_beneficiaries).any?
            op_array << OrdrePaiement.create(dossier: dossier, numero_allocataire: dossier.num_affiliation, echeance_caisse_lot_liquidation_id: lot.id)
          end

          allocations.each_with_index do |allocation, i|
            if all_beneficiaries.include?(allocation.enfant_id)
              if allocation.enfant.beneficiary_associations_to_dps.first.conjoint?
                beneficiary_id = allocation.enfant.beneficiary_associations_to_dps.first.conjoint_id
                type_beneficiary = 'conjoint'
              elsif allocation.enfant.beneficiary_associations_to_dps.first.attributaire?
                beneficiary_id = allocation.enfant.beneficiary_associations_to_dps.first.attributaire_tierce_id
                type_beneficiary = 'attributaire'
              end
              allocation.ordre_paiement = op_array.select { |op| op.beneficiaire_id == beneficiary_id and op.type_beneficiary == type_beneficiary }.first
            else
              allocation.ordre_paiement = op_array.select { |op| op.beneficiaire_id == nil }.first
            end
            puts 'error', allocation.errors.full_messages unless allocation.save
          end

          allocations.each do |allocation|
            next if ComptaTransaction.exists?(dossier: allocation, statut: [:paye, :en_cours])
            compta_transaction = ComptaTransaction.create(
              en_tete: allocation.en_tete_comptabilite,
              dossier: allocation,
              ordre_paiement: allocation.ordre_paiement,
              code_operation: 'PF_AF',
              code_classe_evenement: 'ECHEANCE',
              code_agence_liquidation: code_agence_css || user.agence.try(:code_psrm) || 'C_SG', # à définir
              numero_allocataire: dossier.num_affiliation,
              nom: dossier.nom,
              prenom: dossier.prenom,
              adresse: dossier.adresse_domicile,
              mode_paiement: :caisse_css,
              code_banque_allocataire: nil,
              numero_compte_allocataire: nil,
              date_debut_periode: echeance_caisse.periode_debut,
              date_fin_periode: echeance_caisse.periode_fin,
              montant: allocation.montant_paiement,
              code_devise: 'XOF',
              statut: :en_cours,
              description: "Allocation familiale #{allocation.trimestre}, enfant : #{allocation.enfant.try(:full_name)}",
              admin_agence: user.admin_agence,
              date_comptable: Date.today
            )
          end
        end
      end

      lot.echeance_caisse_liquidations.each { |liquidation|
        liquidation.liquider(user, compta_transaction)
      }
      lot.valide_allocations_par_comptable(user)

      lot.liquide = true
      lot.valide_comptable_par = user
      lot.date_validation_comptable = Date.today
      lot.save!
    end
    set_enfants_not_payable_after_payment
  end

  # @param [User] user
  def retour_temps_presence_valide(user)
    lot = echeance_caisse_lot_liquidations.where(liquide: false).order(id: :asc).last
    return if lot.nil?
    if lot.echeance_caisse_liquidations.destroy_all
      lot.carriere_dossier_prestations.destroy_all
      lot.allocation_familiales.destroy_all
      lot.destroy
    end
    echeance_caisse_dossiers.with_beneficiaries_added.each do |dossier|
      dossier.echeance_caisse_enfants.update_all(payable: true)
    end
  end

  def generate_bordereau_pdf(base_path = ENV['BORDEREAU_CSS_PATH'])
    @echeance = echeance_caisse
    @employeur = self
    @sc_employeur = Psrm::Employeur.find_by_fhnum(self.matric)
    #@dossiers = @employeur.echeance_caisse_dossiers.order('num_affiliation')
    @dossiers = @sc_employeur.nil? ? DossierPrestation.none : @sc_employeur.dossier_prestations.where(etat: :valide, conjoint_id: nil).where("date_naissance + INTERVAL '60 years' >= ?", @echeance.periode_debut).order('num_affiliation')

    base_path += "/#{@echeance.annee}#{@echeance.trimestre}/#{@employeur.code_agence_css || 'XX'}"
    file_name = "BORDEREAU_#{@employeur.code_agence_css || 'XX'}_#{matric}_#{@echeance.annee}#{@echeance.trimestre}"

    ac = ActionController::Base.new()

    pdf = ac.render_to_string(pdf: file_name,
                              page_size: 'A4',
                              template: "admin/echeance_caisses/generate_bordereau_employeur.html.erb",
                              layout: "bordereau_mailer.html",
                              # orientation: "Landscape",
                              lowquality: true,
                              zoom: 1,
                              pi: 75,
                              locals: { echeance: @echeance, employeur: @employeur, dossiers: @dossiers })

    save_path = "#{base_path}/#{file_name}.pdf"

    unless File.directory?(base_path)
      FileUtils.mkdir_p(base_path)
    end

    File.open(save_path, 'wb') do |file|
      file << pdf
    end

    pdf_page = CombinePDF.load("#{base_path}/#{file_name}.pdf")
    pdf_page.number_pages(number_format: " %s ", location: :bottom_right, font_size: 14)
    page_title = 'ETAT DE CONTROLE DU TEMPS DE PRESENCE DES ALLOCATAIRES'
    pdf_page.pages.each do |p|
      next if p == pdf_page.pages[0]
      p.textbox page_title, height: 300, width: 250, y: 675, x: 175
    end
    pdf_page.save "#{base_path}/#{file_name}.pdf"
  end

  def bordereau_download_link
    e = echeance_caisse
    "/download_bordereau_css/#{e.annee}#{e.trimestre}/#{code_agence_css || 'XX'}/BORDEREAU_#{code_agence_css || 'XX'}_#{matric}_#{e.annee}#{e.trimestre}.pdf"
  end

  def get_total_amount
    montant = 0
    self.echeance_caisse_dossiers.each do |dossier|
      montant += dossier.echeance_caisse_enfants.where(liquide: true).includes(:enfant).where(document_valide: true).sum(:montant)
    end
    montant
  end

  def is_first_liquidation(lot)
    echeance_caisse_lot_liquidations.order(created_at: :asc).first == lot
  end
end
