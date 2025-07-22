class CreateEcheanceVeuvesCaisseLotLiquidations < ActiveRecord::Migration[5.2]
  def change
    create_table :echeance_veuves_caisse_lot_liquidations do |t|
      t.references :echeance_veuves_caisse, foreign_key: true, index: { name: 'idx_ech_ve' }
      t.boolean :liquide, default: false

      t.timestamps
    end
  end
end
