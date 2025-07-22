class LigneIcmAvisTiersTransaction < ApplicationRecord

    belongs_to :ordre_paiement, foreign_key: :ordre_paiements_id
    belongs_to :dossier_maternite_avis_tier, foreign_key: :dossier_maternite_avis_tiers_id
    belongs_to :ajoute_par, class_name: 'User', foreign_key: :ajoute_par_id
    
end
