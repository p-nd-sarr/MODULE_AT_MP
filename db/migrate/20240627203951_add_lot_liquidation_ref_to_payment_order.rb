class AddLotLiquidationRefToPaymentOrder < ActiveRecord::Migration[5.2]
  def change
    add_column :ordre_paiements, :echeance_caisse_lot_liquidation_id, :integer
  end
end
