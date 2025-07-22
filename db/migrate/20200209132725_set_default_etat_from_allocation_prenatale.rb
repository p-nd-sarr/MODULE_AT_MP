class SetDefaultEtatFromAllocationPrenatale < ActiveRecord::Migration[5.2]
  def change
    change_column :allocation_prenatales, :etat, :integer, default: 1
    AllocationPrenatale.where(etat: nil).update_all(etat: 1)
  end
end
