class AddStartValidityToAllocationFamiliale < ActiveRecord::Migration[5.2]
  def change
    add_column :allocation_familiales, :date_debut_validite, :date
  end
end
