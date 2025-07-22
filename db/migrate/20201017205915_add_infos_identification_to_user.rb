class AddInfosIdentificationToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :date_naissance, :date
    add_column :users, :lieu_naissance, :string
    add_column :users, :nin, :string
  end
end
