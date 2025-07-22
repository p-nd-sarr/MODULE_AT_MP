class AddIdItemToArretTravails < ActiveRecord::Migration[5.2]
  def change
    add_column :arret_travails, :id_item, :string
  end
end