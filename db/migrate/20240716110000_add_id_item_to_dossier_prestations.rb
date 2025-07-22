class AddIdItemToDossierPrestations < ActiveRecord::Migration[5.2]
  def change
    add_column :dossier_prestations, :id_item, :string
  end
end