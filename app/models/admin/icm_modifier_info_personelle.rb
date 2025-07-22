class Admin::IcmModifierInfoPersonelle < ApplicationRecord
    belongs_to :dossier_maternite, class_name: 'DossierMaternite', foreign_key: :dossier_maternite_id, optional: true
    belongs_to :ajoute_par, class_name: 'User', foreign_key: :ajoute_par_id,  optional: true
end
