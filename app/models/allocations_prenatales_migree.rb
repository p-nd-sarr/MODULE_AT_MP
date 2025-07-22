class AllocationsPrenatalesMigree < ApplicationRecord

  belongs_to :dossier_prestation, foreign_key: :dossier_prestation_id,
             primary_key: :num_dossier,
             optional: true

  belongs_to :conjoint, foreign_key: :conjoint_id, primary_key: :old_conjoint_id, optional: true
end