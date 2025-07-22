class CreateAllocataires < ActiveRecord::Migration[5.2]
  def change
    create_table :allocataires do |t|
      t.string :numero_allocataire, limit: 20, null: false
      t.integer :categorie
      t.string :nom, limit: 250
      t.string :prenom, limit: 250
      t.integer :sexe
      t.integer :nationalite_id
      t.integer :trimestre_naissance
      t.date :date_naissance
      t.integer :type_piece_identification_id
      t.string :numero_identification_nationale, limit: 50
      t.string :situation_matrimoniale_code, limit: 3
      t.integer :type_etat_civil_id
      t.integer :nombre_epouses
      t.integer :nombre_enfants
      t.integer :trimestre_sorti_enfant1
      t.integer :trimestre_sorti_enfant2
      t.integer :trimestre_sorti_enfant3
      t.integer :nombre_enfant_veuve
      t.string :adresse_rue, limit: 250
      t.string :adresse_ville, limit: 250
      t.string :code_pays, limit: 250
      t.string :code_region, limit: 250
      t.string :code_commune, limit: 250
      t.string :telephone, limit: 30

      t.timestamps
    end
  end
end
