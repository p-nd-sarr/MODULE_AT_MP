class CreateDocumentImmatriculations < ActiveRecord::Migration[5.2]
  def change
    create_table :document_immatriculations do |t|
      t.text :commentaire
      t.integer :type_document
      t.references :immatriculation, foreign_key: true

      t.timestamps
    end
  end
end
