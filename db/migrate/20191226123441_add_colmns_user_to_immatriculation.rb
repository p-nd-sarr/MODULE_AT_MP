class AddColmnsUserToImmatriculation < ActiveRecord::Migration[5.2]
  def change

    add_column :immatriculations, :user_id, :bigint

  end
end