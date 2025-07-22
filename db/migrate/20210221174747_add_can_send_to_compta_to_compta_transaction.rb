class AddCanSendToComptaToComptaTransaction < ActiveRecord::Migration[5.2]
  def change
    add_column :compta_transactions, :can_send_to_compta, :boolean, null: false, default: true
  end
end
