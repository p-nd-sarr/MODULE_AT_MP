class AddVisibleForColumnToArretTravails < ActiveRecord::Migration[5.2]
  def change
    add_column :arret_travails, :visible_for, :text
    add_column :arret_travails, :creer_par_ag_direction_at, :boolean, default: false
    add_column :arret_travails, :medecin_conseil_obligatoire, :boolean, default: false
  end
end
