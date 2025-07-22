class AddBeneficiaryValideToRegularisationPension < ActiveRecord::Migration[5.2]
  def change
    add_column :regularisation_pensions, :beneficiaire_valide, :boolean
  end
end
