class CreateAllocationPrenatalesOld < ActiveRecord::Migration[5.2]
  def change
    create_table :allocation_prenatales do |t|
      t.integer :sexe_salarie
      t.string :num_affiliation
      t.string :prenom, null: false
      t.string :nom, null: false
      t.date :date_naissance, null: false
      t.string :lieu_naissance, null: false
      t.string :adresse_domicile
      t.integer :etat, null: false, default: 1
      t.date :date_soumission
      t.boolean :etat_civil_demandeur_valid
      t.boolean :conjoint_valid
      t.boolean :enfants_valid
      t.boolean :document_valid
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
