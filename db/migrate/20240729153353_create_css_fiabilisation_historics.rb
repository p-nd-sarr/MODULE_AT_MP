class CreateCssFiabilisationHistorics < ActiveRecord::Migration[5.2]
  def change
    create_table :css_fiabilisation_historics do |t|
      t.integer :dossier_id
      t.string :dossier_type
      t.string :prenom
      t.string :nom
      t.string :numero_affiliation
      t.string :sexe
      t.date :date_naissance
      t.date :date_mariage
      t.string :ajoute_par_id

      t.timestamps
    end
  end
end
