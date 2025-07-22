class ChangeTypePeiceRepresentant < ActiveRecord::Migration[5.2]
  def change
    change_column :representant_legals, :identity_number, :integer, limit: 8
  end
end
