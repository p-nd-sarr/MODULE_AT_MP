class CreateDocumentDossierPrestations < ActiveRecord::Migration[5.2]
  def change
    create_table :document_dossier_prestations do |t|
      t.references :dossier_prestation, foreign_key: true
      t.integer :type_document
      t.text :commentaire
      t.date :date_depot

      t.timestamps
    end
  end
end
