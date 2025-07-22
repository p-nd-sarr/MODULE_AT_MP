class RenameColumnToCafConjoint < ActiveRecord::Migration[5.2]
  def change
    rename_column :caf_conjoints, :prestation_exterieures_id, :prestation_exterieure_id
  end
end
