class CreateAdminDepartements < ActiveRecord::Migration[5.2]
  def change
    create_table :admin_departements do |t|
      t.references :admin_region, foreign_key: true
      t.string :designation, null: false
      t.integer :code, null: false

      t.timestamps
    end
  end
end
