class ChangeTypeBeneficiaryInOrdrePaiements < ActiveRecord::Migration[5.2]
  def change
    change_column :ordre_paiements, :type_beneficiary, :string
  end
end
