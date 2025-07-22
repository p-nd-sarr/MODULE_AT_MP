class CreateSalarieEnfants < ActiveRecord::Migration[5.2]
  def change
    create_table :salarie_enfants do |t|
      t.references :user, foreign_key: true
      t.string :prenom, null: false
      t.string :nom, null: false
      t.date :date_naissance, null: false
      t.string :nom_mere, null: false
      t.string :prenom_mere, null: false
      t.string :nom_pere
      t.string :prenom_pere
      t.integer :etat, default: 1

      t.timestamps
    end
  end
end
