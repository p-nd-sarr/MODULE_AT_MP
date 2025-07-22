class EcheanceVeuvesCaisseEnfant < ApplicationRecord

  belongs_to :echeance_veuves_caisse
  belongs_to :dossier_prestation
  belongs_to :echeance_veuves_caisse_epouse
  belongs_to :enfant

  has_one :echeance_veuves_caisse_liquidation

end
