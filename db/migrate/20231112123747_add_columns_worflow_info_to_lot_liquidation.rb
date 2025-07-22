class AddColumnsWorflowInfoToLotLiquidation < ActiveRecord::Migration[5.2]
  def change
    add_column :echeance_caisse_lot_liquidations, :liquide_par_id, :integer
    add_column :echeance_caisse_lot_liquidations, :valide_ca_par_id, :integer
    add_column :echeance_caisse_lot_liquidations, :valide_comptable_par_id, :integer
    add_column :echeance_caisse_lot_liquidations, :date_liquidation, :date
    add_column :echeance_caisse_lot_liquidations, :date_validation_ca, :date
    add_column :echeance_caisse_lot_liquidations, :date_validation_comptable, :date
  end
end
