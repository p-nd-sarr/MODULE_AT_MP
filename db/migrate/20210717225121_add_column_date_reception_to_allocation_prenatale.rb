class AddColumnDateReceptionToAllocationPrenatale < ActiveRecord::Migration[5.2]
  def change
    add_column :allocation_prenatales, :date_reception, :date
  end
end
