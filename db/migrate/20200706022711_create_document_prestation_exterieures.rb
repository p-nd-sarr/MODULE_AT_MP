class CreateDocumentPrestationExterieures < ActiveRecord::Migration[5.2]
  def change
    create_table :document_prestation_exterieures do |t|
      t.references :prestation_exterieure, foreign_key: true, index: { name: :prestation_exterieure_id }
      t.integer :type_document

      t.timestamps
    end
  end
end
