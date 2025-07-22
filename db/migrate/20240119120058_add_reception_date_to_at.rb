class AddReceptionDateToAt < ActiveRecord::Migration[5.2]
  def change
    add_column :arret_travails, :date_reception, :date
  end
end
