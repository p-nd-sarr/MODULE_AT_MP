class ChangeMultipleColumnTypeToArretTravails < ActiveRecord::Migration[5.2]
  def change
    change_column :arret_travails, :status_ipress, :string
    change_column :arret_travails, :status_css, :string
    change_column :arret_travails, :status_ipress_css, :string
  end
end
