class AddNinToPrestationExtFrance < ActiveRecord::Migration[5.2]
  def change
    add_column :cfs_reversion_veuves, :numero_piece, :string
    add_column :cfs_reversion_veuves, :type_piece, :integer

  end
end
