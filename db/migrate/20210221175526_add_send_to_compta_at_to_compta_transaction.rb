class AddSendToComptaAtToComptaTransaction < ActiveRecord::Migration[5.2]
  def change
    add_column :compta_transactions, :send_to_compta_at, :datetime
  end
end
