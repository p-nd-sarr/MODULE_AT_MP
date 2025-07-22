class UpdateAllocationMigreeBeneficiaireColumn < ActiveRecord::Migration[5.2]
  def change
    change_column :allocations_familiales_migrees, :beneficiaire_id, :string
    change_column :allocations_familiales_migrees, :beneficiaire_prenom, :string
    change_column :allocations_familiales_migrees, :beneficiaire_nom, :string

    change_column :allocations_prenatales_migrees, :beneficiaire_id, :string
    change_column :allocations_prenatales_migrees, :beneficiaire_prenom, :string
    change_column :allocations_prenatales_migrees, :beneficiaire_nom, :string

    change_column :allocations_postnatales_migrees, :beneficiaire_id, :string
    change_column :allocations_postnatales_migrees, :beneficiaire_prenom, :string
    change_column :allocations_postnatales_migrees, :beneficiaire_nom, :string

  end
end
