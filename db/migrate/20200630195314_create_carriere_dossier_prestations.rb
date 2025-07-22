class CreateCarriereDossierPrestations < ActiveRecord::Migration[5.2]
  def change
    create_table :carriere_dossier_prestations do |t|
      t.references :dossier_prestation, foreign_key: true
      t.date :date_depot
      t.string :num_employeur
      t.string :raison_sociale
      t.date :date_document
      t.integer :trimestre
      t.boolean :infos_jour
      t.boolean :infos_heure
      t.integer :premier_mois
      t.integer :deuxiem_mois
      t.integer :troisiem_mois

      t.timestamps
    end
  end
end
