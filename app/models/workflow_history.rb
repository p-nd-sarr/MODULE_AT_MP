class WorkflowHistory < ApplicationRecord
  belongs_to :dossier, polymorphic: true
  belongs_to :user, optional: true
end
