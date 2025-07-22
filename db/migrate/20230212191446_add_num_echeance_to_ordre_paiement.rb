class AddNumEcheanceToOrdrePaiement < ActiveRecord::Migration[5.2]
  def change
    add_column :ordre_paiements, :num_echeance, :string
  end
end
