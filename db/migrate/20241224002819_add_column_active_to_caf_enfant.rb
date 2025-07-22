class AddColumnActiveToCafEnfant < ActiveRecord::Migration[5.2]
  def change
    add_column :caf_enfants, :active, :boolean, default: true
  end
end
