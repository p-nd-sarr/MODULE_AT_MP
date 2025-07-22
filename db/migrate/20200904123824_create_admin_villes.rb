class CreateAdminVilles < ActiveRecord::Migration[5.2]
  def change
    create_table :admin_villes do |t|
      t.references :admin_departement, foreign_key: true
      t.integer :code, null: false
      t.string :designation, null: false

      t.timestamps
    end
  end
end
