class AddDescriptionToComptaTransaction < ActiveRecord::Migration[5.2]
  def change
    add_column :compta_transactions, :description, :string
  end
end
