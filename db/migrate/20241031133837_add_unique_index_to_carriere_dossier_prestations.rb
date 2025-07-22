class AddUniqueIndexToCarriereDossierPrestations < ActiveRecord::Migration[5.2]
  def change
    add_index :carriere_dossier_prestations,
              [:dossier_prestation_id, :trimestre, :annee],
              unique: true,
              name: 'index_unique_on_carriere_dossier_prestations_trimestre_annee'
  end
end
