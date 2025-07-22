class CreateAdminCities < ActiveRecord::Migration[5.2]
  def change
    create_table :admin_cities do |t|
      t.references :admin_countries, null: false
      t.string :description, null: false

      t.timestamps
    end
  end
end
