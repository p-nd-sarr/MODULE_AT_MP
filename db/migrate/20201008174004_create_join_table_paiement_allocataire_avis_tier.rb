class CreateJoinTablePaiementAllocataireAvisTier < ActiveRecord::Migration[5.2]
  def change
    create_join_table :paiement_allocataires, :avis_tiers do |t|
      # t.index [:paiement_allocataire_id, :avis_tier_id]
      t.index [:avis_tier_id, :paiement_allocataire_id], name: 'index_avis_tiers_paiement_allocataires'
    end
  end
end
