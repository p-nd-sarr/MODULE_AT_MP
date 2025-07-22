class CreateAdminQuartiers < ActiveRecord::Migration[5.2]
  def change
    create_table :admin_quartiers do |t|
      t.references :admin_commune, foreign_key: true
      t.integer :code, null: false
      t.string :designation, null: false

      t.timestamps
    end
  end
end
