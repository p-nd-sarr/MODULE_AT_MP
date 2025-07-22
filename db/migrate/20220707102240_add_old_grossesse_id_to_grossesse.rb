class AddOldGrossesseIdToGrossesse < ActiveRecord::Migration[5.2]
  def change
    add_column :grossesses, :old_grossesse_id, :string
  end
end
