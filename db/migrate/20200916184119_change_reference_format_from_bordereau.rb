class ChangeReferenceFormatFromBordereau < ActiveRecord::Migration[5.2]
  def change
    change_column :bordereau_salaries_assocs, :participant_id, :string
  end
end
