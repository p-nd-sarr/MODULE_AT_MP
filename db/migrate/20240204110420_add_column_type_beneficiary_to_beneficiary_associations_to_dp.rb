class AddColumnTypeBeneficiaryToBeneficiaryAssociationsToDp < ActiveRecord::Migration[5.2]
  def change
    add_column :beneficiary_associations_to_dps, :type_beneficiary, :integer
    BeneficiaryAssociationsToDp.where.not(conjoint_id: nil).update_all(type_beneficiary: 1)
    BeneficiaryAssociationsToDp.where.not(attributaire_tierce_id: nil).update_all(type_beneficiary: 2)
  end
end
