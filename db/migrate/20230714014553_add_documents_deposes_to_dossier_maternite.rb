class AddDocumentsDeposesToDossierMaternite < ActiveRecord::Migration[5.2]
  def change
    add_column :dossier_maternites, :documents_deposes_obligatoires, :text, array: true, default: []
    add_column :dossier_maternites, :documents_deposes_facultatifs, :text, array: true, default: []
  end
end
