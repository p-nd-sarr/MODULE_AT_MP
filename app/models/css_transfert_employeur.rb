class CssTransfertEmployeur < ApplicationRecord

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
  belongs_to :psrm_employeur, :class_name => 'Psrm::Employeur', foreign_key: :employeur_matric, primary_key: :fhnum

  validates :employeur_matric, :date_transfert, :agence_destination, :agence_source, presence: true

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
    dossier_pfs = DossierPrestation.where(employeur_actuel: employeur_matric, agence_id: agence_source_id)
    employer = Psrm::Employeur.where(fhnum: employeur_matric)
    emp_ecs = EcheanceCaisseEmployeur.where(matric: employeur_matric)
    dossier_mat = DossierMaternite.where(num_immatriculation: employeur_matric)

    # update all dossier pf agency
    dossier_pfs.update_all(agence_id: agence_destination_id)

    # update  employer code agency
    employer.update_all(code_agence_css: Admin::Agence.find(agence_destination_id).code_psrm)

    # update all ech employer agency
    emp_ecs.each do |e|
      if e.can_go_back?
        e.update(code_agence_css: Admin::Agence.find(agence_destination_id).code_psrm)
      end
    end

    # update all dossier mat agency
    dossier_mat.update_all(admin_agence_id: agence_destination_id)

    self.valide_par = User.current
    self.date_validation = DateTime.now
    if self.retourne_par
      self.motif_retour = nil
      self.date_retour = nil
      self.retourne_par = nil
    end
    self.save!
  end

end
