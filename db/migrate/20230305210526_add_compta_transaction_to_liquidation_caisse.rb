class AddComptaTransactionToLiquidationCaisse < ActiveRecord::Migration[5.2]
  def change
    add_column :echeance_caisse_liquidations, :compta_transaction_id, :integer, index: true
  end
end
