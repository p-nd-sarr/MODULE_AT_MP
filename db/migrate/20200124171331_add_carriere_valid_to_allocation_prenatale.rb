class AddCarriereValidToAllocationPrenatale < ActiveRecord::Migration[5.2]
  def change
    add_column :allocation_prenatales, :carriere_valid, :boolean, null: false, default: false
    add_column :allocation_prenatales, :date_jouissance, :date

  end
end
