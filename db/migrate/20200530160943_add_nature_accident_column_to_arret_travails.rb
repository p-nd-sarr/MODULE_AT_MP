class AddNatureAccidentColumnToArretTravails < ActiveRecord::Migration[5.2]
  def change
    add_column :arret_travails, :nature_accident, :integer
  end
end
