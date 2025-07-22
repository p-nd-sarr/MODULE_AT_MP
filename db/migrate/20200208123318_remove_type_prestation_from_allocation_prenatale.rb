class RemoveTypePrestationFromAllocationPrenatale < ActiveRecord::Migration[5.2]
  def change
    remove_column :allocation_prenatales, :type_prestation
  end
end
