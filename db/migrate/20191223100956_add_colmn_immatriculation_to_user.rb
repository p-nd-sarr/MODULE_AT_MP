class AddColmnImmatriculationToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :num_immatriculation, :string
  end
end