class CreateCafConjoints < ActiveRecord::Migration[5.2]
  def change
      create_table :caf_conjoints do |t|
        t.string :prenom
        t.string :nom
        t.string :nom_jeune_fille
        t.date :date_naissance
        t.string :lieu_naissance
        t.date :date_mariage
        t.date :date_separation
        t.date :date_divorce
        t.string :adresse_precise
        t.references :prestation_exterieures, foreign_key: true

      t.timestamps
    end
  end
end
