class CreateDocumentDossierMaternites < ActiveRecord::Migration[5.2]
  def change
    create_table :document_dossier_maternites do |t|
      t.references :dossier_maternite, foreign_key: true
      t.integer :type_document
      t.text :commentaire
      t.date :date_depot

      t.timestamps
    end
  end
end
