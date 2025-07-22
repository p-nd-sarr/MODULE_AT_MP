class ChangeModePaiementTypeFromComptaTransaction < ActiveRecord::Migration[5.2]
  def self.up
    ComptaTransaction.destroy_all
    change_column :compta_transactions, :mode_paiement, :integer, using: 'mode_paiement::integer'
  end

  def self.down
    change_column :compta_transactions, :mode_paiement, :string
  end
end
