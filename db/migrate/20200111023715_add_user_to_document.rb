class AddUserToDocument < ActiveRecord::Migration[5.2]
  def change
    add_column :document_immatriculations, :user_id, :bigint
    add_column :salarie_immatriculations  , :user_id, :bigint

  end
end
