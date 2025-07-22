class AddColumnMotifRejetToAllocationFamiliale < ActiveRecord::Migration[5.2]
  def change
    add_column :allocation_familiales, :motif_rejet, :integer
  end
end
