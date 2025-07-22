class AddColumnDocumentValidToPrestationExterieures < ActiveRecord::Migration[5.2]
  def change
    add_column :prestation_exterieures, :document_valid, :boolean
  end
end
