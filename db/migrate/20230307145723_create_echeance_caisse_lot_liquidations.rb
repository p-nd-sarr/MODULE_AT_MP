class CreateEcheanceCaisseLotLiquidations < ActiveRecord::Migration[5.2]
  def change
    create_table :echeance_caisse_lot_liquidations do |t|
      t.references :echeance_caisse, foreign_key: true, index: {name: 'idx_eclt_ec1'}
      t.references :echeance_caisse_employeur, foreign_key: true, index: {name: 'idx_eclt_ece1'}
      t.boolean :liquide, default: false

      t.timestamps
    end

    add_reference :echeance_caisse_liquidations, :echeance_caisse_lot_liquidation, foreign_key: true, index: {name: 'idx_ecl_eclt1'}
  end
end
