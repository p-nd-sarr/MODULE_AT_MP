class UpdateColumnNameToMoratoire2 < ActiveRecord::Migration[5.2]
  def change
    rename_column :factures, :declarations_id, :declaration_id

  end
end
