class RenameAllocationMigreeVoletColumn < ActiveRecord::Migration[5.2]
  def change
    rename_column :allocations_prenatales_migrees, :Volet, :volet
    rename_column :allocations_postnatales_migrees, :Volet, :volet
  end
end
