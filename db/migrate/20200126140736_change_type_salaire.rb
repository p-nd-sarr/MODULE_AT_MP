class ChangeTypeSalaire < ActiveRecord::Migration[5.2]
  def change

    change_column :salarie_immatriculations, :salaire_contractuel, :float, using: 'salaire_contractuel::float '
  end
end