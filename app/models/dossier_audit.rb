class DossierAudit < ApplicationRecord

  include WorkflowActiverecord
  include Documentable

  workflow_column :workflow_state

  workflow do
    state :creation, :meta => { label: 'Création' } do
      event :est_soumis, transition_to: :soumission, meta: { label: 'Soumettre dossier au chef de service', types_profils: [:auditeur], back: false }
    end

    state :soumission, :meta => { label: 'Soumission' } do
      event :est_soumis_directeur, transition_to: :soumission_directeur, meta: { label: 'Soumettre dossier au directeur', types_profils: [:chef_service_audit, :chef_service_controle_interne], back: false }
      event :retour_creation, transition_to: :creation, meta: { label: 'Retourner dossier', types_profils: [:chef_service_audit], back: true }
    end

    state :soumission_directeur, :meta => { label: 'Soumission directeur' } do
      event :est_valide, transition_to: :validation, meta: { label: 'Valider dossier', types_profils: [:directeur_audit], back: false }
      event :retour_soumission, transition_to: :soumission, meta: { label: 'Retourner dossier', types_profils: [:directeur_audit], back: true }
    end

    state :validation, :meta => { label: 'Validation' } do
      event :est_cloture, transition_to: :cloturation, meta: { label: 'Cloturation dossier', types_profils: [:directeur_audit], back: false } do
        halt! 'Toutes les activités doivent être validées' unless can_cloture?
      end
    end

    state :cloturation, :meta => { label: 'Cloturation' }

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

  TYPE_DOCUMENT_OBLIGATOIRE = {

  }.freeze

  TYPE_DOCUMENT = TYPE_DOCUMENT_OBLIGATOIRE.merge(
    {
      lettre_de_mission: 1
    }
  ).freeze

  scope :en_attente_validation_chef_service, -> { where(workflow_state: [:soumission]) }
  scope :en_attente_validation_directeur, -> { where(workflow_state: [:soumission_directeur]) }

  belongs_to :ajoute_par, class_name: 'User', foreign_key: :ajoute_par_id
  belongs_to :soumis_par, class_name: 'User', foreign_key: :soumis_par_id, optional: true
  belongs_to :soumis_directeur_par, class_name: 'User', foreign_key: :soumis_directeur_par_id, optional: true
  belongs_to :valide_par, class_name: 'User', foreign_key: :valide_par_id, optional: true
  belongs_to :cloture_par, class_name: 'User', foreign_key: :cloture_par_id, optional: true
  belongs_to :rejete_par, class_name: 'User', foreign_key: :rejete_par_id, optional: true
  belongs_to :agence, class_name: 'Admin::Agence', foreign_key: :admin_agence_id, optional: true

  has_many :dossier_audit_affectations, foreign_key: :dossier_audits_id
  has_many :dossier_audit_activities, foreign_key: :dossier_audits_id
  has_many :activity_recommandations, foreign_key: :dossier_audits_id

  before_create :set_numero_dossier!

  def set_numero_dossier!
    annee = Date.today.year
    if DossierAudit.exists?(created_at: (DateTime.now.beginning_of_year..DateTime.now.end_of_year))
      dernier_dossier_ajoute = DossierAudit.where(created_at: (DateTime.now.beginning_of_year..DateTime.now.end_of_year)).order('created_at DESC').first
      self.num_dossier = dernier_dossier_ajoute.num_dossier.next
    else
      self.num_dossier = "#{annee}/DOSSAUD0001"
    end
  end

  def est_soumis(user)
    self.soumis_par = user
    self.date_soumission = Date.today
    if self.motif_rejet?
      self.motif_rejet = nil
    end
    self.save!
  end

  def est_soumis_directeur(user)
    self.soumis_directeur_par = user
    self.date_soumission_directeur = Date.today
    if self.motif_rejet?
      self.motif_rejet = nil
    end
    self.save!
  end

  def est_valide(user)
    self.valide_par = user
    self.date_validation = Date.today
    if self.motif_rejet?
      self.motif_rejet = nil
    end
    self.save!
  end

  def est_cloture(user)
    self.cloture_par = user
    self.date_cloture = Date.today
    self.save!
  end

  def can_cloture?
    self.dossier_audit_activities.where(workflow_state: :creation).length == 0
  end

  def set_as_agent_chosen(agent_id)
    dossier_affactation = DossierAuditAffectation.new
    dossier_affactation.affecte_par = User.current
    dossier_affactation.affecte_a_id = agent_id
    dossier_affactation.date_affectation = Date.today
    dossier_affactation.dossier_audits_id = self.id
    dossier_affactation.save
  end

  def is_not_agent_chosen_anymore(agent_id)
    dossier_affactation = DossierAuditAffectation.where(dossier_audits_id: self.id, affecte_a_id: agent_id).first
    dossier_affactation.destroy
  end

  def is_set_manager(agent_id)
    DossierAuditAffectation.exists?(dossier_audits_id: self.id, affecte_a_id: agent_id)
  end

  def make_activity_ready(activity_id)
    activity = DossierAuditActivity.find(activity_id)
    activity.update(is_ready: true)
  end
end
