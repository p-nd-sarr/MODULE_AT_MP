class AddNumDossierColumnToArretTravails < ActiveRecord::Migration[5.2]
  def change
    add_column :arret_travails, :num_dossier, :string
  end
end
