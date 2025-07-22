class RenameFieldTypeRegimeCarriere < ActiveRecord::Migration[5.2]
  def change
    rename_column :carrieres, :type_regime, :type_regime_id
  end
end
