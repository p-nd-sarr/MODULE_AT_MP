class AddMontantSubventionToComptaTransaction < ActiveRecord::Migration[5.2]
  def change
    add_column :compta_transactions, :montant_subvention, :float
  end
end
