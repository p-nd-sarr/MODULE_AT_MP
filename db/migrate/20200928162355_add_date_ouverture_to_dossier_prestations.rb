class AddDateOuvertureToDossierPrestations < ActiveRecord::Migration[5.2]
  def change
    add_column :dossier_prestations, :date_ouverture, :date
  end
end
