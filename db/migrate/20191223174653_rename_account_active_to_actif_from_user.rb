class RenameAccountActiveToActifFromUser < ActiveRecord::Migration[5.2]
  def change
    rename_column :users, :account_active, :actif
  end
end
