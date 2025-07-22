class AddColumnEstPaysCafToCountries < ActiveRecord::Migration[5.2]
  def change
    add_column :admin_countries, :est_pays_caf, :boolean
  end
end
