class AddSubrogationInArretTravail < ActiveRecord::Migration[5.2]
  def change
    add_column :arret_travails, :is_subrogation, :boolean, default: false
  end
end
