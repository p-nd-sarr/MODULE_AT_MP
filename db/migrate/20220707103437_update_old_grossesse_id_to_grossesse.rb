class UpdateOldGrossesseIdToGrossesse < ActiveRecord::Migration[5.2]
  def change
    change_column :grossesses, :old_grossesse_id, :integer, using: 'old_grossesse_id::integer'
  end
end
