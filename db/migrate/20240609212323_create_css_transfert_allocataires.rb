class CreateCssTransfertAllocataires < ActiveRecord::Migration[5.2]
  def change
    create_table :css_transfert_allocataires do |t|
      t.string :workflow_state
      t.string :numero_affiliation
      t.string :employeur_source
      t.string :employeur_destination
      t.string :agence_source_id
      t.string :agence_destination_id
      t.date :date_transfert
      t.integer :ajoute_par_id
      t.integer :soumis_par_id
      t.integer :valide_par_id
      t.integer :retourne_par_id
      t.date :date_soumission
      t.date :date_validation
      t.boolean :information_valid
      t.string :commentaire
      t.text :motif_retour
      t.date :date_retour

      t.timestamps
    end
  end
end
