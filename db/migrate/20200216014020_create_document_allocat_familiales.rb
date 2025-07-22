class CreateDocumentAllocatFamiliales < ActiveRecord::Migration[5.2]
  def change
    create_table :document_allocat_familiales do |t|
      t.references :allocation_familiale, foreign_key: true
      t.integer :type_document
      t.text :commentaire
      t.date :date_depot

      t.timestamps
    end
  end
end
