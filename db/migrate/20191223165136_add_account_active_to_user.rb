class AddAccountActiveToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :account_active, :boolean, null: false, default: false
  end
end
