class CreateCafEnfants < ActiveRecord::Migration[5.2]
  def change
    create_table :caf_enfants do |t|
      t.string :prenom
      t.string :nom
      t.date :date_naissance
      t.string :lieu_naissance
      t.string :lien_parente
      t.string :observations
      t.references :caf_conjoints, foreign_key: true
    end
  end
end
