class AddColumnBeneficiaireToPaymentOrder < ActiveRecord::Migration[5.2]
  def change
    add_column :ordre_paiements, :beneficiaire_id, :integer
  end
end
