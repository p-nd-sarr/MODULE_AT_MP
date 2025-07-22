class AddBankIdAndBankBranchIdToComptaTransaction < ActiveRecord::Migration[5.2]
  def change
    add_column :compta_transactions, :bank_id, :string
    add_column :compta_transactions, :bank_branch_id, :string
  end
end
