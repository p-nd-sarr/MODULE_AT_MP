class CreateMpDocuments < ActiveRecord::Migration[5.2]
  def change
    create_table :mp_documents do |t|
      t.string :libelle
      t.string :code
      t.integer :type_document
      t.text :description
      t.references :maladie_professionnelle, foreign_key: true

      t.timestamps
    end
  end
end
