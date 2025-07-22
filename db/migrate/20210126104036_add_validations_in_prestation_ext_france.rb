class AddValidationsInPrestationExtFrance < ActiveRecord::Migration[5.2]
  def change
    add_column :cfs_reversion_veuves, :epouses_valide, :boolean, null: false, default: false
    add_column :cfs_reversion_veuves, :enfants_valide, :boolean, null: false, default: false
  end
end
