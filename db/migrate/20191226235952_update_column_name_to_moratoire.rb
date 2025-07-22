class UpdateColumnNameToMoratoire < ActiveRecord::Migration[5.2]
  def change
    rename_column :moratoires, :factures, :references
  end
end
