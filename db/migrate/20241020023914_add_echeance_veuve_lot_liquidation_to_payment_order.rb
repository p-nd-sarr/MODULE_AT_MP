class AddEcheanceVeuveLotLiquidationToPaymentOrder < ActiveRecord::Migration[5.2]
  def change
    add_column :ordre_paiements, :echeance_veuves_caisse_lot_liquidation_id, :integer
  end
end
