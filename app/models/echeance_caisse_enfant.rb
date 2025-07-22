class EcheanceCaisseEnfant < ApplicationRecord
  belongs_to :echeance_caisse
  belongs_to :dossier_prestation
  belongs_to :echeance_caisse_dossier
  belongs_to :enfant

  has_one :echeance_caisse_liquidation
end
