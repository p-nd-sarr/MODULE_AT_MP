class RemoveEnfantValidFromAllocationPrenatale < ActiveRecord::Migration[5.2]
  def change
    remove_column :allocation_prenatales, :enfants_valid

  end
end
