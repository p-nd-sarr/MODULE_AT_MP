class CreateDossierCnavs < ActiveRecord::Migration[5.2]
  def change
    create_table :dossier_cnavs do |t|
      t.string :numero_dossier
      t.date :date_ouverture
      t.integer :etat
      t.integer :mois
      t.integer :annee
      t.string :motif_rejet
      t.date :date_soumission
      t.integer :soumis_par_id
      t.date :date_validation
      t.integer :valide_par_id
      t.integer :ajoute_par_id
      t.datetime :traite_le
      t.integer :traite_par_id
      t.integer :admin_region_id
      t.integer :admin_agence_id
      t.integer :agence_creation_id
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
