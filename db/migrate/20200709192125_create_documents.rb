class CreateDocuments < ActiveRecord::Migration[5.2]
  def change
    create_table :documents do |t|
      t.references :documentable, polymorphic: true, null: false
      t.integer :type_document, null: false
      t.text :commentaire

      t.timestamps
    end
  end
end
