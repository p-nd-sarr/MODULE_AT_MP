class AddDateAndMotifRejetToAllocationPrenatale < ActiveRecord::Migration[5.2]
  def change
    add_column :allocation_prenatales, :date_rejet, :date
  end
end
