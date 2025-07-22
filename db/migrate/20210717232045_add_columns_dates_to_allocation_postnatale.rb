class AddColumnsDatesToAllocationPostnatale < ActiveRecord::Migration[5.2]
  def change
    add_column :allocation_postnatales, :date_reception, :date
    add_column :allocation_postnatales, :date_enregistrement, :date
  end
end
