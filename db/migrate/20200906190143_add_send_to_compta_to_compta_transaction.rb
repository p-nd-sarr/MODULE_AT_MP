class AddSendToComptaToComptaTransaction < ActiveRecord::Migration[5.2]
  def change
    add_column :compta_transactions, :send_to_compta, :boolean, default: false, null: false
  end
end
