class EcheanceVeuvesCaisseEpouse < ApplicationRecord

  belongs_to :echeance_veuves_caisse
  belongs_to :admin_agence, :class_name => 'Admin::Agence'
  belongs_to :dossier_prestation
  has_many :echeance_veuves_caisse_enfants

  def montant_liquidation(lot)
    liquidations = lot.echeance_veuves_caisse_liquidations
    self.echeance_veuves_caisse_enfants.where(id: liquidations.pluck(:echeance_veuves_caisse_enfant_id)).sum(:montant)
  end

  def nombre_enfants_liquidation(lot)
    liquidations = lot.echeance_veuves_caisse_liquidations
    self.echeance_veuves_caisse_enfants.where(id: liquidations.pluck(:echeance_veuves_caisse_enfant_id)).pluck('distinct enfant_id').count
  end

  def nombre_mois_liquidation(lot)
    liquidations = lot.echeance_veuves_caisse_liquidations
    self.echeance_veuves_caisse_enfants.where(id: liquidations.pluck(:echeance_veuves_caisse_enfant_id)).pluck(:enfant_id).count
  end

  def ordre_paiement(lot)
    conjoint = Conjoint.find(self.conjoint_id)
    enfants = conjoint.enfants
    compta_transaction = EcheanceVeuvesCaisseLiquidation.joins(:echeance_veuves_caisse_enfant).where(echeance_veuves_caisse_lot_liquidation_id: lot.id).where(echeance_veuves_caisse_enfants: { enfant_id: enfants.pluck(:id) }).first.compta_transaction
    compta_transaction.ordre_paiement
  end

  def get_payment_order(lot)
    OrdrePaiement.find_by(dossier: dossier_prestation, beneficiaire_id: conjoint_id, echeance_veuves_caisse_lot_liquidation_id: lot.id).id unless OrdrePaiement.find_by(dossier: dossier_prestation, beneficiaire_id: conjoint_id, echeance_veuves_caisse_lot_liquidation_id: lot.id).nil?
  end

end
