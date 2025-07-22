class AddFinValidityToAllocationFamiliale < ActiveRecord::Migration[5.2]
  def change
    add_column :allocation_familiales, :date_fin_validite, :date
  end
end
