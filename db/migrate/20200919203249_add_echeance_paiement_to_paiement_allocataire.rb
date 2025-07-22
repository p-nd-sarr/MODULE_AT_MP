class AddEcheancePaiementToPaiementAllocataire < ActiveRecord::Migration[5.2]
  def change
    add_reference :paiement_allocataires, :echeance_paiement, foreign_key: true, null: true
  end
end
