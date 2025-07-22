class AddColummnTypeToBordereau < ActiveRecord::Migration[5.2]
  def change
    add_column :bordereau_collectifs, :bordereau_type, :integer, :default => 1
  end
end
