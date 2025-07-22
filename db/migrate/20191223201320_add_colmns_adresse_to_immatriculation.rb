class AddColmnsAdresseToImmatriculation < ActiveRecord::Migration[5.2]
  def change
    add_column :immatriculations, :region, :integer, default: 0
    add_column :immatriculations, :departement, :integer, default: 0
    add_column :immatriculations, :ville, :integer, default: 0
    add_column :immatriculations, :commune, :integer, default: 0
    add_column :immatriculations, :quartier , :integer, default: 0
  end
end
