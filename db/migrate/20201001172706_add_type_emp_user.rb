class AddTypeEmpUser < ActiveRecord::Migration[5.2]
  def change

    add_column :users, :type_employeur, :integer
    add_column :users, :fonction, :string
    add_column :users, :numero_unique, :string
  end
end
