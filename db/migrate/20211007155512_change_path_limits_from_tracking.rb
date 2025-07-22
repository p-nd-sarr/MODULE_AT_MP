class ChangePathLimitsFromTracking < ActiveRecord::Migration[5.2]
  def change
    change_column :trackings, :path, :string, limit: 500
    change_column :trackings, :path_source, :string, limit: 500
  end
end
