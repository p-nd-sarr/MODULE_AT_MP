class CreateAllocatairePfs < ActiveRecord::Migration[5.2]
  def change
    create_table :allocataire_pfs do |t|
      t.string :numero_allocataire, limit: 20, null: false
      t.string :nom, limit: 250
      t.string :prenom, limit: 250
      t.date :date_naissance
      t.string :lieu_naissance
      t.integer :sexe
      t.integer :regime_matrimoniale
      t.integer :nombre_conjoint
      t.integer :nationalite_id
      t.integer :type_national
      t.string :adresse
      t.string :numero_employeur
      t.string :adresse_employeur
      t.integer :mode_paiement
      t.string :telephone, limit: 30

      t.timestamps
    end
  end
end
