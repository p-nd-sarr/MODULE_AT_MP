class AddDateComptableToComptaTransaction < ActiveRecord::Migration[5.2]
  def change
    add_column :compta_transactions, :date_comptable, :datetime
  end
end
