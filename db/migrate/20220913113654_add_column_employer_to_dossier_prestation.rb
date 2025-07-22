class AddColumnEmployerToDossierPrestation < ActiveRecord::Migration[5.2]
  def change
    add_column :dossier_prestations, :employeur_actuel, :string, :limit => 20
  end
end
