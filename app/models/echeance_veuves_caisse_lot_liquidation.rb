class EcheanceVeuvesCaisseLotLiquidation < ApplicationRecord

  belongs_to :echeance_veuves_caisse
  belongs_to :liquide_par, class_name: 'User', foreign_key: :liquide_par_id, optional: true
  belongs_to :valide_ca_par, class_name: 'User', foreign_key: :valide_ca_par_id, optional: true
  belongs_to :valide_comptable_par, class_name: 'User', foreign_key: :valide_comptable_par_id, optional: true
  has_many :echeance_veuves_caisse_liquidations
  has_many :allocation_familiales
  has_many :ordre_paiements

  def montant_total
    liquidations = self.echeance_veuves_caisse_liquidations
    EcheanceVeuvesCaisseEnfant.where(id: liquidations.pluck(:echeance_veuves_caisse_enfant_id)).sum(:montant)
  end

  def nombre_mois
    self.echeance_veuves_caisse_liquidations.count
  end

  def nombre_enfants
    liquidations = self.echeance_veuves_caisse_liquidations
    EcheanceVeuvesCaisseEnfant.where(id: liquidations.pluck(:echeance_veuves_caisse_enfant_id)).pluck('distinct enfant_id').count
  end
end
