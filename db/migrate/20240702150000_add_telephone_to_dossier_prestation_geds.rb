class AddTelephoneToDossierPrestationGeds < ActiveRecord::Migration[5.2]
  def change
    add_column :dossier_prestation_geds, :telephone, :string
  end
end