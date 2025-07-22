class AddIdRepriseToComptaTransaction < ActiveRecord::Migration[5.2]
  def change
    add_column :compta_transactions, :id_reprise, :integer
    add_index :compta_transactions, :id_reprise
  end
end
