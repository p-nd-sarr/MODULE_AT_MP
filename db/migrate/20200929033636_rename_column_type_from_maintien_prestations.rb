class RenameColumnTypeFromMaintienPrestations < ActiveRecord::Migration[5.2]
  def change
    rename_column :maintien_prestations, :type, :type_maintien
  end
end
