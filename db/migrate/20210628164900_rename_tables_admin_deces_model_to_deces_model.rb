class RenameTablesAdminDecesModelToDecesModel < ActiveRecord::Migration[5.2]
  def change
    rename_table :admin_deces_enfants, :deces_enfants
    rename_table :admin_deces_salaries, :deces_salaries
  end
end
