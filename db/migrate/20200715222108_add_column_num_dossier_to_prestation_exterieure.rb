class AddColumnNumDossierToPrestationExterieure < ActiveRecord::Migration[5.2]
  def change
    add_column :prestation_exterieures, :numero_dossier, :string
  end
end
