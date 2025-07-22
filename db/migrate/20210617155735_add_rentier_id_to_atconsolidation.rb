class AddRentierIdToAtconsolidation < ActiveRecord::Migration[5.2]
  def change
    add_column :at_consolidations, :rentier_id, :integer
  end
end
