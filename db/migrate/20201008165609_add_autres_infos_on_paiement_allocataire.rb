class AddAutresInfosOnPaiementAllocataire < ActiveRecord::Migration[5.2]
  def change
    add_reference :paiement_allocataires, :pret_allocataire_ligne, foreign_key: true, null: true
    add_reference :paiement_allocataires, :avis_tier, foreign_key: true, null: true
  end
end
