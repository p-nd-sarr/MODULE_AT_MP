class AddserToEntity < ActiveRecord::Migration[5.2]
  def change

    add_column :moratoires  , :user_id, :bigint
    add_column :declarations  , :user_id, :bigint
    add_column :paiements  , :user_id, :bigint
    add_column :factures  , :user_id, :bigint

  end
end
