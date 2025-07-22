class CreateAdminRegions < ActiveRecord::Migration[5.2]
  def change
    create_table :admin_regions do |t|
      t.string :designation, null: false
      t.integer :code
      t.string :pays

      t.timestamps
    end
  end
end
