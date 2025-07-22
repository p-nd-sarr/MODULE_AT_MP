class RemovePretAndAvisTierFromPaiementAllocataire < ActiveRecord::Migration[5.2]
  def change
    remove_column :paiement_allocataires, :avis_tier_id
    remove_column :paiement_allocataires, :pret_allocataire_ligne_id
  end
end
