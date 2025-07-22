class CreateIndemniteCongesMaternites < ActiveRecord::Migration[5.2]
  def change
    create_table :indemnite_conges_maternites do |t|
      t.references :dossier_prestation, foreign_key: true
      t.date :date_soumission
      t.date :date_validation
      t.integer :valide_par_id
      t.references :user, foreign_key: true
      t.integer :ajoute_par_id
      t.datetime :traite_le
      t.integer :traite_par_id
      t.string :motif_rejet
      t.integer :montant_paiement
      t.boolean :paiement
      t.integer :etat
      t.integer :tranche_paiement
      t.date :debut_grossesse
      t.date :debut_conges
      t.date :date_accouchement
      t.date :date_reprise_service

      t.timestamps
    end
  end
end
