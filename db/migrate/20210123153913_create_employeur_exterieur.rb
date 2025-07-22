class CreateEmployeurExterieur < ActiveRecord::Migration[5.2]
  def change
    create_table :employeur_exterieurs do |t|
      t.string :prenom_employeur
      t.string :nom_employeur
      t.string :raison_sociale
      t.string :email
      t.string :adresse
      t.string :telephone

      t.timestamps
    end
  end
end
