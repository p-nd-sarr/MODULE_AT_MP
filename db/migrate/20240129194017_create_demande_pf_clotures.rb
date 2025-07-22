class CreateDemandePfClotures < ActiveRecord::Migration[5.2]
  def change
    create_table :demande_pf_clotures do |t|
      t.string :workflow_state
      t.references :admin_agence
      t.references :dossier_prestation
      t.integer :soumis_par_id
      t.integer :valide_par_id
      t.integer :annuler_par_id
      t.text :motif_annulation
      t.date :date_validation
      t.date :date_annulation

      t.timestamps
    end
  end
end
