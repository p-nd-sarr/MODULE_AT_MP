class AddColumnDateRejetToAllocationF < ActiveRecord::Migration[5.2]
  def change
    add_column :allocation_familiales, :date_rejet, :date
  end
end
