class AddZonesToComptaTransaction < ActiveRecord::Migration[5.2]
  def change
    add_column :compta_transactions, :zone, :integer, null: true
    add_reference :compta_transactions, :admin_region, foreign_key: true, null: true
  end
end
