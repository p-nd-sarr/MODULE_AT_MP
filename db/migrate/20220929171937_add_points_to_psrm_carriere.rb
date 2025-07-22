class AddPointsToPsrmCarriere < ActiveRecord::Migration[5.2]
  def change
    add_column :psrm_carrieres, :points_rc, :integer, default: 0, null: false
    add_column :psrm_carrieres, :points_rg, :integer, default: 0, null: false
  end
end
