class AddDateInterruptionToGrossesse < ActiveRecord::Migration[5.2]
  def change
    add_column :grossesses, :date_interruption, :date
  end
end
