class CreateLigneIcmAvisTiersTransactions < ActiveRecord::Migration[5.2]
  def change
    create_table :ligne_icm_avis_tiers_transactions do |t|
      t.references :dossier_maternite_avis_tiers, index: { name: :avis_tiers_icm }
      t.references :ordre_paiements
      t.float :montant
      t.integer :ajoute_par_id
      t.float :montant_paye
      t.date :date_paiement

      t.timestamps
    end
  end
end
