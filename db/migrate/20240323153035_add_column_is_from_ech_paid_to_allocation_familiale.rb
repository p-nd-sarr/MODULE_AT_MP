class AddColumnIsFromEchPaidToAllocationFamiliale < ActiveRecord::Migration[5.2]
  def change
    add_column :allocation_familiales, :is_from_ech_paid, :boolean
  end
end
