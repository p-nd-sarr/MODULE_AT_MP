class AddColumnNombreFemmeToSalarie < ActiveRecord::Migration[5.2]
  def change
    add_column :salaries, :nombre_femme, :integer
  end
end
