class ChangeOpTyBeneficiaryColumn < ActiveRecord::Migration[5.2]
  def change
    change_column :ordre_paiements, :type_beneficiary, 'integer USING CAST(type_beneficiary AS integer)'
  end
end
