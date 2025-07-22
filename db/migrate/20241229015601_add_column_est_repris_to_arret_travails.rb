class AddColumnEstReprisToArretTravails < ActiveRecord::Migration[5.2]
  def change
    add_column :arret_travails, :est_repris, :boolean, default: false
  end
end
