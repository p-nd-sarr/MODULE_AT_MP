class CreateEcheanceVeuvesCaisseLiquidations < ActiveRecord::Migration[5.2]
  def change
    create_table :echeance_veuves_caisse_liquidations do |t|
      t.references :echeance_veuves_caisse_lot_liquidation, foreign_key: true, index: { name: 'idx_ech_lot_liq' }
      t.references :echeance_veuves_caisse_enfant, foreign_key: true, index: { name: 'idx_ech_liq' }
      t.integer :compta_transaction_id, index: { name: 'idx_cp_trans' }
      t.boolean :liquide, default: false

      t.timestamps
    end
  end
end
