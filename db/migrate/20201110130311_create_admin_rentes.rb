class CreateAdminRentes < ActiveRecord::Migration[5.2]
  def change
    create_table :admin_rentes do |t|
      t.integer :age
      t.float :prix
      t.timestamps
    end
  end
end
