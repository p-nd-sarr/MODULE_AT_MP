class CreateDeclarationSalaireManquantes < ActiveRecord::Migration[5.2]
  def change
    create_table :declaration_salaire_manquantes do |t|
      t.string :numero, limit: 20, null: false
      t.string :raison_sociale
      t.integer :zone
      t.string :adresse
      t.integer :exercice, null: false
      t.integer :regime, null: false
      t.string :telephone, limit: 30
      t.integer :effectif
      t.string :code_agence, limit: 5

      t.timestamps
    end
  end
end
