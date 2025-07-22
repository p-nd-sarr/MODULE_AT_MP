class AddNumDossierToDossierPrestation < ActiveRecord::Migration[5.2]
  def change
    add_column :dossier_prestations, :num_dossier, :string
  end
end
