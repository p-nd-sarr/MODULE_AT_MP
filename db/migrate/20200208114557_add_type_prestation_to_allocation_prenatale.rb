class AddTypePrestationToAllocationPrenatale < ActiveRecord::Migration[5.2]
  def change
    add_column :allocation_prenatales, :type_prestation, :boolean
  end
end
