class AddColumnsToSalarie < ActiveRecord::Migration[5.2]
  def change
    add_column :salaries, :etat, :integer
    add_column :salaries, :date_deces, :date
  end
end
