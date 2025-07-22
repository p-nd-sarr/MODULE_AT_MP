class RenameColumnToCafEnfant < ActiveRecord::Migration[5.2]
  def change
    rename_column :caf_enfants, :caf_conjoints_id, :caf_conjoint_id
  end
end
