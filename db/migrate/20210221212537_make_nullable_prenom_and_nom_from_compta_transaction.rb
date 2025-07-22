class MakeNullablePrenomAndNomFromComptaTransaction < ActiveRecord::Migration[5.2]
  def change
    change_column_null :compta_transactions, :prenom, true
    change_column_null :compta_transactions, :nom, true
  end
end
