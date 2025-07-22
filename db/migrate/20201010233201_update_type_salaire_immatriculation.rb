class UpdateTypeSalaireImmatriculation < ActiveRecord::Migration[5.2]
  def change

    remove_column :salarie_immatriculations, :salaire_contractuel

    add_column :salarie_immatriculations, :salaire_contractuel, :float, :default => 0.0
  end
end
