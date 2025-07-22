class AddSinfoSalaryProValidToArretTravail < ActiveRecord::Migration[5.2]
  def change
    add_column :arret_travails, :info_pro_salarie_valid, :boolean, :default => false
  end
end
