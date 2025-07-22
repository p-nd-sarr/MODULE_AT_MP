class RemoveAllocationPrenatale < ActiveRecord::Migration[5.2]
  def change
    drop_table :document_allocation_prenatales
    drop_table :allocation_prenatales
  end
end
