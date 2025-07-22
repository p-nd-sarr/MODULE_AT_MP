class DossierAuditActivity < ApplicationRecord

  include WorkflowActiverecord
  include Documentable

  workflow_column :workflow_state

  workflow do
    state :creation, :meta => { label: 'Création' } do
      event :est_soumis, transition_to: :soumission, meta: { label: 'Soumettre', types_profils: [:auditeur], back: false }
    end

    state :soumission, :meta => { label: 'Soumission' } do
      event :est_valide, transition_to: :validation, meta: { label: 'Validation', types_profils: [:chef_service_audit], back: false }
      event :retour_creation, transition_to: :creation, meta: { label: 'Retourner', types_profils: [:chef_service_audit], back: true }
    end

    state :validation, :meta => { label: 'Validation' }

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

  belongs_to :dossier_audit, foreign_key: :dossier_audits_id
  belongs_to :ajoute_par, class_name: 'User', foreign_key: :ajoute_par_id
  belongs_to :soumis_par, class_name: 'User', foreign_key: :soumis_par_id, optional: true
  belongs_to :valide_par, class_name: 'User', foreign_key: :valide_par_id, optional: true
  has_many :activity_recommandations, foreign_key: :dossier_audit_activities_id

  scope :en_attente_validation_chef_service, -> { where(workflow_state: [:soumission]) }

  def est_soumis(user)
    self.soumis_par = user
    self.date_soumission = Date.today
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
end

