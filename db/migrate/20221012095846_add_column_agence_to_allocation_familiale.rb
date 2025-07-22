class AddColumnAgenceToAllocationFamiliale < ActiveRecord::Migration[5.2]
  def change
    add_reference :allocation_familiales, :admin_agence, index: true
  end
end
