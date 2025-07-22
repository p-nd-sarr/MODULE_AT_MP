class AddInfosPaiementToComptaTransaction < ActiveRecord::Migration[5.2]
  def change
    add_column :compta_transactions, :mode_paiement, :string
  end
end
