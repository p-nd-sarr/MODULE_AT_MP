class AddDeletedColumnToArretTravails < ActiveRecord::Migration[5.2]
  def change
    add_column :arret_travails, :deleted, :boolean
  end
end
