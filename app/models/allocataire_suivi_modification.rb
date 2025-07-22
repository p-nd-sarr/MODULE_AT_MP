class AllocataireSuiviModification < ApplicationRecord
  belongs_to :dossier_revision, polymorphic: true, optional: true
  belongs_to :allocataire
end