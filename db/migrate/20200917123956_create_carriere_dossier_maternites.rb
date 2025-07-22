class CreateCarriereDossierMaternites < ActiveRecord::Migration[5.2]
  def change
    create_table :carriere_dossier_maternites do |t|
      t.references :dossier_maternite, foreign_key: true
      t.date :date_depot
      t.string :num_employeur
      t.string :raison_sociale
      t.date :date_document
      t.integer :trimestre
      t.integer :annee
      t.boolean :en_jour
      t.boolean :en_heure
      t.integer :premier_mois
      t.integer :deuxiem_mois
      t.integer :troisiem_mois

      t.timestamps
    end
  end
end
