module ActsAsWorkflowHistory
  extend ActiveSupport::Concern

  included do
    has_many :workflow_histories, as: :dossier, dependent: :destroy
  end
end
