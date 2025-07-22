class AddColumnToSalarieImm < ActiveRecord::Migration[5.2]
  def change
    add_column :salarie_immatriculations, :etat, :integer, default: 1
  end
end
