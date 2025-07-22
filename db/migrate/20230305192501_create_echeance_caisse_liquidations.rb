class CreateEcheanceCaisseLiquidations < ActiveRecord::Migration[5.2]
  def change
    create_table :echeance_caisse_liquidations do |t|
      t.references :echeance_caisse_employeur, foreign_key: true, index: { name: 'idx_ece1' }
      t.references :echeance_caisse_enfant, foreign_key: true, index: { name: 'idx_ece2' }
      t.boolean :liquide, default: false

      t.timestamps
    end
  end
end
