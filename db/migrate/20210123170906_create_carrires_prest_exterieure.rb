class CreateCarriresPrestExterieure < ActiveRecord::Migration[5.2]
  def change
    create_table :carrires_prest_exterieures do |t|
      t.references :employeur_exterieurs, foreign_key: true, null: true
      t.references :cfs_reversion_veuves, foreign_key: true, null: true
      t.date :date_debut
      t.date :date_fin
      t.integer :type_regime
      t.float :salaire
      t.string :motif_rejet
      t.integer :etat
      t.datetime :date_traitement
      t.integer :traite_par_id
      t.timestamps
    end
  end
end
