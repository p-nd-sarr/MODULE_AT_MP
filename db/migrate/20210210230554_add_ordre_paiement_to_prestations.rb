class AddOrdrePaiementToPrestations < ActiveRecord::Migration[5.2]
  def change
    add_reference :allocation_prenatales, :ordre_paiement, null: true
    add_reference :allocation_postnatales, :ordre_paiement, null: true
    add_reference :allocation_familiales, :ordre_paiement, null: true
  end
end
