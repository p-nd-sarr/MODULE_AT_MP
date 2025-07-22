class AddLotLiquidationTImeOfPresence < ActiveRecord::Migration[5.2]
  def change
    add_reference :carriere_dossier_prestations, :echeance_caisse_lot_liquidation, foreign_key: true, index: { name: 'tp_echeance_lot_id' }
  end
end
