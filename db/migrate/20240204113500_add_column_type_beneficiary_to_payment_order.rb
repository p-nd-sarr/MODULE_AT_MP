class AddColumnTypeBeneficiaryToPaymentOrder < ActiveRecord::Migration[5.2]
  def change
    add_column :ordre_paiements, :type_beneficiary, :integer
    OrdrePaiement.where.not(beneficiaire_id: nil).where(type_beneficiary: nil).update_all(type_beneficiary: 1)
  end
end
