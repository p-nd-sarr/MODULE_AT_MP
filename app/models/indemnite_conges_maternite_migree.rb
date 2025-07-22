class IndemniteCongesMaterniteMigree < ApplicationRecord
  belongs_to :dossier_maternite, foreign_key: :dossier_maternite_id,
             primary_key: :old_dossier_maternite_id,
             optional: true
end
