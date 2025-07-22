class CreateDossierPrestationGeds < ActiveRecord::Migration[5.2]
  def change
    create_table :dossier_prestation_geds do |t|
      t.string :num_affiliation
      t.integer :sexe_salarie
      t.string :prenom
      t.string :nom
      t.string :lieu_naissance
      t.string :adresse_domicile
      t.date :date_naissance
      t.string :nin
      t.integer :nationalite
      t.string :employeur_actuel
      t.date :date_embauche
      t.integer :admin_agence_id
      t.string :num_dossier
      t.date :date_reception
      t.string :id_item
      t.string :lien_ged
      t.integer :etat
      t.string :status_ged

      t.timestamps
    end
  end
end