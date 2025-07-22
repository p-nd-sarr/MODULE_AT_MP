class DemandePfCloture < ApplicationRecord

  include WorkflowActiverecord

  MOTIF = {
    licenciement: 1,
    demission: 2,
    fonctionnaire: 3,
    autres: 4
  }.freeze
  enum motif: MOTIF

  workflow_column :workflow_state

  workflow do

    state :soumis, :meta => { label: 'Soumis' } do
      event :est_valide, transition_to: :valide
      event :est_rejete, transition_to: :valide
    end

    state :valide, :meta => { label: 'Validé' }
    state :rejete, :meta => { label: 'Rejeté' }

  end

  belongs_to :dossier_prestation
  belongs_to :admin_agence, :class_name => 'Admin::Agence'
  belongs_to :soumis_par, class_name: 'User', foreign_key: :soumis_par_id
  belongs_to :valide_par, class_name: 'User', foreign_key: :valide_par_id, optional: true
  belongs_to :annule_par, class_name: 'User', foreign_key: :annuler_par_id, optional: true

  has_one_attached :document_justificatif
  validates :document_justificatif, attached: true, content_type: { in: 'application/pdf', message: "n'est pas un PDF" }
end
