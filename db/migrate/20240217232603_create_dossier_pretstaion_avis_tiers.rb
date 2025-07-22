class CreateDossierPretstaionAvisTiers < ActiveRecord::Migration[5.2]
  def change
    create_table :dossier_pretstaion_avis_tiers do |t|
      t.string :num_affiliation
      t.integer :type_avis
      t.integer :etat
      t.float :montant_avis
      t.float :montant_echeance
      t.integer :ajouter_par_id
      t.integer :soumis_par_id
      t.integer :valider_par_id
      t.date :date_soumission
      t.date :date_validation

      t.timestamps
    end
  end
end
