class AddEstMpToArretTravails < ActiveRecord::Migration[5.2]
  def change
    add_column :arret_travails, :est_mp, :boolean, default: false
  end
end