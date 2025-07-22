class CreateDossierMaternites < ActiveRecord::Migration[5.2]
  def change
    create_table :dossier_maternites do |t|
      t.string :num_affiliation
      t.string :prenom
      t.string :nom
      t.date :date_naissance
      t.string :lieu_naissance
      t.string :adresse_domicile
      t.boolean :etat_civil_demandeur_valid
      t.boolean :carriere_valid
      t.boolean :document_valid
      t.references :user, foreign_key: true
      t.date :debut_grossesse
      t.integer :etat
      t.date :date_soumission
      t.integer :ajoute_par_id
      t.datetime :traite_le
      t.integer :traite_par_id
      t.string :motif_rejet
      t.string :num_dossier

      t.timestamps
    end
  end
end
