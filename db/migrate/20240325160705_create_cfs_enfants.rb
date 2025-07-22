class CreateCfsEnfants < ActiveRecord::Migration[5.2]
  def change
    create_table :cfs_enfants do |t|
      t.references :liquidation_retraite_france, foreign_key: true
      t.string :prenom
      t.string :nom
      t.date :date_naissance
      t.string :lieu_naissance
      t.integer :filiation
      t.boolean :situation
      t.date :date_deces
      t.integer :etat
      t.integer :ajoute_par_id

      t.timestamps
    end
  end
end
