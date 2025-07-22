class CreateDossierPrestationHistorics < ActiveRecord::Migration[5.2]
  def change
    create_table :dossier_prestation_historics do |t|
      t.references :dossier_prestation
      t.references :admin_agence
      t.string :employeur_matric
      t.date :date_embauche
      t.boolean :is_current

      t.timestamps
    end
  end
end
