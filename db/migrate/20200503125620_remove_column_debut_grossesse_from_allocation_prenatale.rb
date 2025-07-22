class RemoveColumnDebutGrossesseFromAllocationPrenatale < ActiveRecord::Migration[5.2]
  def change
    remove_column :allocation_prenatales, :debut_grossesse
  end
end
