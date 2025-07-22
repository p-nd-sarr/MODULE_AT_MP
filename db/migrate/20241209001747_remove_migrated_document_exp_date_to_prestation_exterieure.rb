class RemoveMigratedDocumentExpDateToPrestationExterieure < ActiveRecord::Migration[5.2]
  def change
    remove_column :prestation_exterieures, :migrated_document_exp_date
  end
end
