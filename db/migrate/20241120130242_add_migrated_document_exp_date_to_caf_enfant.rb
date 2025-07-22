class AddMigratedDocumentExpDateToCafEnfant < ActiveRecord::Migration[5.2]
  def change
    add_column :prestation_exterieures, :migrated_document_exp_date, :date
  end
end
