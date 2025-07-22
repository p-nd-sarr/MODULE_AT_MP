class CreateIndemniteCongesMaterniteMigrees < ActiveRecord::Migration[5.2]
  def change
    create_table :indemnite_conges_maternite_migrees do |t|

      t.integer :dossier_maternite_id
      t.integer :montant_paiement
      t.integer :num_tranche
      t.integer :jours_prolongation
      t.integer :numdro_liquidation
      t.date :debut_grossesse
      t.date :debut_conges
      t.date :date_accouchement
      t.date :date_reprise_service
      t.date :date_liquidation
      t.date :date_reprise_reelle

      t.timestamps
    end
  end
end
