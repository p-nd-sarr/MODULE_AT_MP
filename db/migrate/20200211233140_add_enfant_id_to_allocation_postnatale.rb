class AddEnfantIdToAllocationPostnatale < ActiveRecord::Migration[5.2]
  def change
    add_column :allocation_postnatales, :enfant_id, :integer
  end
end
