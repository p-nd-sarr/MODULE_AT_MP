class RemoveColumnsFromComptaTransaction < ActiveRecord::Migration[5.2]
  def change
    remove_column :compta_transactions, :branche, :string
    remove_column :compta_transactions, :legal_entity_id, :integer
  end
end
