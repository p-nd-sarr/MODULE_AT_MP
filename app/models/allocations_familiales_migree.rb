class AllocationsFamilialesMigree < ApplicationRecord

  belongs_to :dossier_prestation, foreign_key: :dossier_prestation_id,
             primary_key: :num_dossier,
             optional: true

  belongs_to :enfant, foreign_key: :enfant_id, primary_key: :old_id, optional: true
end
