class CreateCfsConjoints < ActiveRecord::Migration[5.2]
  def change
    create_table :cfs_conjoints do |t|
      t.references :liquidation_retraite_france, foreign_key: true
      t.string :prenom
      t.string :nom
      t.date :date_naissance
      t.string :lieu_naissance
      t.integer :nationalite_id
      t.string :prenom_pere
      t.string :nom_pere
      t.string :prenom_mere
      t.string :nom_mere
      t.string :numero_immatriculation
      t.date :date_mariage
      t.boolean :situation
      t.date :date_deces
      t.integer :etat
      t.integer :ajoute_par_id

      t.timestamps
    end
  end
end
