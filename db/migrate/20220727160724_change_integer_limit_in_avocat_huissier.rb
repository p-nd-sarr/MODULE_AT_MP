class ChangeIntegerLimitInAvocatHuissier < ActiveRecord::Migration[5.2]
  def change
    change_column :avocats_huissiers, :nin, :integer, limit: 8
  end
end
