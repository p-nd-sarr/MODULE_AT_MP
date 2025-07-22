class CreateAdminLocaliteGrappes < ActiveRecord::Migration[5.2]
  def change
    create_table :admin_localite_grappes do |t|
      t.integer :code_pays
      t.integer :code_localite
      t.string :localite

      t.timestamps
    end
  end
end
