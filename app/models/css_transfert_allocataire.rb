class CssTransfertAllocataire < ApplicationRecord

  include WorkflowActiverecord
  include Documentable

  workflow_column :workflow_state

  workflow do
    state :creation, :meta => { label: 'Création' } do
      event :valider_informations, transition_to: :informations_valide, meta: { label: 'Valider les informations', types_profils: [:gestionnaire_compte_allocataire, :chef_agence], back: false }
    end

    state :informations_valide, meta: { label: 'Informations valides' } do
      event :est_soumis, transition_to: :soumission, meta: { label: "Soumettre demande de transfert", types_profils: [:chef_agence], back: false }
      event :retourner_creation_chef, transition_to: :creation, meta: { label: 'Annuler Validation informations', types_profils: [:chef_agence], back: true }
      event :retourner_creation_gestionnaire, transition_to: :creation, meta: { label: 'Annuler Validation informations', types_profils: [:gestionnaire_compte_allocataire], back: false }
    end

    state :soumission, :meta => { label: 'Soumission' } do
      event :est_valide, transition_to: :validation, meta: { label: 'Valider demande de transfert', types_profils: [:chef_agence], back: false }
      event :retourner_informations_valide, transition_to: :informations_valide, meta: { label: 'Retourner', types_profils: [:chef_agence], back: true }
    end

    state :validation, :meta => { label: 'Validation' } do
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

  belongs_to :ajoute_par, class_name: 'User', foreign_key: :ajoute_par_id, optional: true
  belongs_to :soumis_par, class_name: 'User', foreign_key: :soumis_par_id, optional: true
  belongs_to :valide_par, class_name: 'User', foreign_key: :valide_par_id, optional: true
  belongs_to :retourne_par, class_name: 'User', foreign_key: :retourne_par_id, optional: true
  belongs_to :agence_source, optional: true, :class_name => 'Admin::Agence', foreign_key: :agence_source_id
  belongs_to :agence_destination, optional: true, :class_name => 'Admin::Agence', foreign_key: :agence_destination_id
  belongs_to :employeur_source, :class_name => 'Psrm::Employeur', foreign_key: :employeur_source_id, primary_key: :fhnum
  belongs_to :employeur_destination, :class_name => 'Psrm::Employeur', foreign_key: :employeur_destination_id, primary_key: :fhnum
  belongs_to :psrm_participant, :class_name => 'Psrm::Participant', foreign_key: :numero_affiliation, primary_key: :matric

  validates :date_embauche, :employeur_destination, :employeur_source, :numero_affiliation, :date_transfert, :agence_destination, :agence_source, presence: true

  scope :en_agence, ->(id) { where(agence_source_id: id) }

  # @param [User] user
  def can_display(user)
    (creation? and user.admin_agence == ajoute_par.admin_agence) or
      (informations_valide? and user.admin_agence.id == agence_destination_id.to_i and user.admin_agence == ajoute_par.admin_agence) or
      (soumission? and user.admin_agence.id == agence_source_id.to_i)
  end

  # @param [User] user
  def valider_informations(user)
    self.motif_retour = nil
    self.date_retour = nil
    self.retourne_par = nil
    self.soumis_par = nil
    self.date_soumission = nil
    self.information_valid = true
    self.save!
  end

  def retourner_creation_chef(user)
    self.retourne_par = User.current
    self.date_retour = DateTime.now
    self.information_valid = false
    self.save!
  end

  def retourner_creation_gestionnaire(user)
    self.retourne_par = User.current
    self.date_retour = DateTime.now
    self.information_valid = false
    self.save!
  end

  def retourner_informations_valide(user)
    self.retourne_par = User.current
    self.date_retour = DateTime.now
    self.soumis_par = nil
    self.date_soumission = nil
    self.save!
  end

  def retourner_soumission(user)
    self.retourne_par = User.current
    self.date_retour = DateTime.now
    self.valide_par = nil
    self.date_validation = nil
    self.save!
  end

  # @param [User] user
  def est_soumis(user)
    self.soumis_par = User.current
    self.date_soumission = DateTime.now
    if self.retourne_par
      self.motif_retour = nil
      self.date_retour = nil
      self.retourne_par = nil
    end
    self.save!
  end

  # @param [User] user
  def est_valide(user)
    CssTransfertAllocataire.transaction do
      # Retrieve all dossiers for the current affiliation and employer
      dossier_pfs = DossierPrestation.where(num_affiliation: numero_affiliation, employeur_actuel: employeur_source_id)
      first_dossier = dossier_pfs.find_by(conjoint_id: nil)

      # Set dossier prestation historic for the first dossier without a conjoint
      if first_dossier
        first_dossier.set_dossier_historic
      else
        raise ActiveRecord::RecordNotFound, "No dossier found without conjoint for historique"
      end

      # Update all dossiers' agency and employer
      dossier_pfs.update_all(agence_id: agence_destination_id, employeur_actuel: employeur_destination_id, date_embauche: date_embauche)

      dossier_pfs = DossierPrestation.where(num_affiliation: numero_affiliation, employeur_actuel: employeur_destination_id)
      first_dossier = dossier_pfs.find_by(conjoint_id: nil)

      # Set dossier prestation historic for the first dossier without a conjoint
      if first_dossier
        first_dossier.set_dossier_historic(Date.today)
      else
        raise ActiveRecord::RecordNotFound, "No dossier found without conjoint for historique"
      end

      # Update EcheanceCaisseDossier records
      ech_dossiers = EcheanceCaisseDossier.where(num_affiliation: numero_affiliation, employeur_actuel: employeur_source_id)
      ech_dossiers.each do |dossier|
        dossier.get_out_of_echeance_after_transfer
      end

      # Update validation details
      self.valide_par = User.current
      self.date_validation = DateTime.now

      # Reset return details if present
      if self.retourne_par
        self.motif_retour = nil
        self.date_retour = nil
        self.retourne_par = nil
      end

      # Save the current record with validation details
      self.save!
    end
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotFound => e
    # Log the error and handle as necessary
    Rails.logger.error "Validation failed: #{e.message}"
    raise
  end

end
