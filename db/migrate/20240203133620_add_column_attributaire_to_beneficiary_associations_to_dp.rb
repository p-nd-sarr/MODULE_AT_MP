class AddColumnAttributaireToBeneficiaryAssociationsToDp < ActiveRecord::Migration[5.2]
  def change
    add_column :beneficiary_associations_to_dps, :attributaire_tierce_id, :integer
  end
end
