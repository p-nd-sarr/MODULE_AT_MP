class AddCodeCaissePaiementToAllocataire < ActiveRecord::Migration[5.2]
  def change
    add_column :allocataires, :code_caisse_paiement, :string, limit: 3
  end
end
