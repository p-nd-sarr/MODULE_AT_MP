class AddSexeToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :sexe, :integer
  end
end
