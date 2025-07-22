class CreateAdminCommunes < ActiveRecord::Migration[5.2]
  def change
    create_table :admin_communes do |t|
      t.references :admin_ville, foreign_key: true
      t.integer :code, null: false
      t.string :designation, null: false

      t.timestamps
    end
  end
end
