class UpdateColumnAgenceIdInDossierPrestation < ActiveRecord::Migration[5.2]
  def change
    change_column :dossier_prestations, :agence_id, :integer, limit: 8
  end
end
