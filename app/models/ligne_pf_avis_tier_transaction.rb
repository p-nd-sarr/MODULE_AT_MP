class LignePfAvisTierTransaction < ApplicationRecord

  belongs_to :ordre_paiement, foreign_key: :ordre_paiements_id
  belongs_to :dossier_prestation_avis_tier, foreign_key: :dossier_prestation_avis_tiers_id
  belongs_to :ajoute_par, class_name: 'User', foreign_key: :ajoute_par_id
end
