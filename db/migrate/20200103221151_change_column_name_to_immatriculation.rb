class ChangeColumnNameToImmatriculation < ActiveRecord::Migration[5.2]
  def change
    change_column :immatriculations, :type_immatriculation, :integer, using: 'type_immatriculation::integer'
    change_column :immatriculations, :type_etablissement, :integer, using: 'type_etablissement::integer'
  end
end