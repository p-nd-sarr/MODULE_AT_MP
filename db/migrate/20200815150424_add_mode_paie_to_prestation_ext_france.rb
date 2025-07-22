class AddModePaieToPrestationExtFrance < ActiveRecord::Migration[5.2]
  def change
    add_column :cfs_reversion_veuves, :motif_rejet, :string
    add_column :cfs_reversion_veuves, :email, :string
  end
end
