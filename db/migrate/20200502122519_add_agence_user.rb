class AddAgenceUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :agence, :integer
  end
end
