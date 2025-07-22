class AddDateReceptionToDossierPrestations < ActiveRecord::Migration[5.2]
  def change
    add_column :dossier_prestations, :date_reception, :date
  end
end
