class AddIndexToEcheanceCaisseLotLiquidations < ActiveRecord::Migration[5.2]
  def change
    add_index :echeance_caisse_lot_liquidations, [:echeance_caisse_id, :echeance_caisse_employeur_id], unique: true, where: "liquide = false", name: "index_echeance_caisse_lot_on_echeance_caisse_and_employeur"
  end
end
