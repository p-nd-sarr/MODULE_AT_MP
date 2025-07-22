class CreateDossierPrestations < ActiveRecord::Migration[5.2]
  def change
    create_table :dossier_prestations do |t|
      t.integer :sexe_salarie
      t.string :num_affiliation
      t.string :prenom
      t.string :nom
      t.date :date_naissance
      t.string :lieu_naissance
      t.string :adresse_domicile
      t.integer :etat
      t.date :date_soumission
      t.date :date_validation
      t.integer :valide_par_id
      t.boolean :etat_civil_demandeur_valid
      t.boolean :carriere_valid
      t.boolean :conjoint_valid
      t.boolean :enfants_valid
      t.boolean :document_valid
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
