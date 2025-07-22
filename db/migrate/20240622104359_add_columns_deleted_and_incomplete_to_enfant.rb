class AddColumnsDeletedAndIncompleteToEnfant < ActiveRecord::Migration[5.2]
  def change
    add_column :enfants, :deleted, :boolean, default: false
    add_column :enfants, :incomplete, :boolean, default: false
  end
end
