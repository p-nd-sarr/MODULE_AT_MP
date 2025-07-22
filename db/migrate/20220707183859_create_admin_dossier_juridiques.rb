class CreateAdminDossierJuridiques < ActiveRecord::Migration[5.2]
  def change
    create_table :dossier_juridiques do |t|

      t.string :nom_dossier
      t.string :num_dossier
      t.string :description_dossier
      t.string :objet_dossier
      t.string :parties
      t.string :requerent
      t.string :defendeur
      t.string :nature_litige
      t.string :etat_procedure
      t.string :agence_concerne
      t.string :direction_concerne
      t.string :montant_reclame

      t.integer :ajoute_par_id

      t.integer :soumis_par_id
      t.date :date_soumission

      t.integer :cloture_par_id
      t.date :date_cloture

      t.string :workflow_state

      t.references :admin_type_dossier_juridique, foreign_key: true

      t.timestamps
    end
  end
end
