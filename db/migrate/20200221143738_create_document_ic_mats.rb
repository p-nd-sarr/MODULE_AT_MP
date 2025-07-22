class CreateDocumentIcMats < ActiveRecord::Migration[5.2]
  def change
    create_table :document_ic_mats do |t|
      t.references :indemnite_conges_maternite, foreign_key: true
      t.integer :type_document
      t.text :commentaire
      t.date :date_depot

      t.timestamps
    end
  end
end
