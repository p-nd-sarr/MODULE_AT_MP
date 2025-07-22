class AddCountryToAdminRegion < ActiveRecord::Migration[5.2]
  def self.up
    add_reference :admin_regions, :admin_country, foreign_key: true, null: true
    unless Admin::Country.find_by(code: 'SEN').nil?
      Admin::Region.where(code_pays: 'SEN').update_all(admin_country_id: Admin::Country.find_by(code: 'SEN').id)
    end
    change_column_null :admin_regions, :admin_country_id, false
    remove_column :admin_regions, :code_pays
  end

  def self.down
    add_column :admin_region, :code_pays, :string
    unless Admin::Country.find_by(code: 'SEN').nil?
      Admin::Region.where(admin_country_id: Admin::Country.find_by(code: 'SEN').id).update_all(code_pays: 'SEN')
    end
    remove_reference :admin_regions, :admin_country
  end
end
