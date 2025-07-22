class AddColmnsToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :num_css, :string
    add_column :users, :num_ipres, :string
    add_column :users, :ninea, :string
    add_column :users, :raison_sociale, :string
    add_column :users, :adresse, :string
  end
end