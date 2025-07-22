class AddColumnDateDecesToEnfant < ActiveRecord::Migration[5.2]
  def change
    add_column :enfants, :date_deces, :date
  end
end
