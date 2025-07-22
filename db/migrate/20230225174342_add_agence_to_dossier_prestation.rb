class AddAgenceToDossierPrestation < ActiveRecord::Migration[5.2]
  def change
    add_column :dossier_prestations, :agence_id, :integer
  end
end
