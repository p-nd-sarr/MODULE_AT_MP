class UpdateColumnDateDeces < ActiveRecord::Migration[5.2]
  def change
    remove_column :admin_deces_enfants, :date_deces
    add_column :admin_deces_enfants, :date_deces, :date
  end
end
