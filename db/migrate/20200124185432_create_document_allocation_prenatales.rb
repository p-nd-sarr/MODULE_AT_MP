class CreateDocumentAllocationPrenatales < ActiveRecord::Migration[5.2]
  def change
    create_table :document_allocation_prenatales do |t|
      t.references :allocation_prenatale, foreign_key: true
      t.integer :type_document
      t.text :commentaire

      t.timestamps
    end
  end
end
