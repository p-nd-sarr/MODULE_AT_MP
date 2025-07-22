class AddAdressePaiementToAllocataire < ActiveRecord::Migration[5.2]
  def change
    add_column :allocataires, :adresse_paiement, :string
  end
end
