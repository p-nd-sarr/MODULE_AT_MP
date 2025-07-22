class RenameColumnCountryInAdminCities < ActiveRecord::Migration[5.2]
  def change
    rename_column :admin_cities, :admin_countries_id, :admin_country_id
  end
end
