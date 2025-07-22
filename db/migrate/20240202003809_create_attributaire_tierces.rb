class CreateAttributaireTierces < ActiveRecord::Migration[5.2]
  def change
    create_table :attributaire_tierces do |t|
      t.string :workflow_state
      t.string :prenom
      t.string :nom
      t.string :nin
      t.integer :ajoute_par_id
      t.integer :soumis_par_id
      t.integer :valide_par_id
      t.integer :cloture_par_id
      t.integer :rejete_par_id
      t.text :motif_rejet
      t.date :date_soumission
      t.date :date_validation
      t.date :date_cloturation
      t.date :date_rejet
      t.references :dossier_prestation

      t.timestamps
    end
  end
end
