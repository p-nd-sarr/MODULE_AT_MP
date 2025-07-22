class AddDateFinRegulToRegularisationPension < ActiveRecord::Migration[5.2]
  def change
    add_column :regularisation_pensions, :date_fin_regularisation, :date
    add_column :regularisation_pensions, :date_debut_regularisation, :date
    add_column :regularisation_pensions, :autre_montant, :float
  end
end
