class RemoveVoletFromAllocationPrenatale < ActiveRecord::Migration[5.2]
  def change
    remove_column :allocation_prenatales, :volet
  end
end
