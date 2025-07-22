class CreateLignePfAvisTierTransactions < ActiveRecord::Migration[5.2]
  def change
    create_table :ligne_pf_avis_tier_transactions do |t|
      t.references :dossier_prestation_avis_tiers, index: { name: :avis_tiers_is }
      t.references :ordre_paiements
      t.float :montant
      t.integer :ajoute_par_id

      t.timestamps
    end
  end
end
