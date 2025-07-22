class CreateAtDocuments < ActiveRecord::Migration[5.2]
  def change
    create_table :at_documents do |t|
      t.string :libelle
      t.string :code
      t.integer :type_document
      t.text :description
      t.references :arret_travail, foreign_key: true

      t.timestamps
    end
  end
end
