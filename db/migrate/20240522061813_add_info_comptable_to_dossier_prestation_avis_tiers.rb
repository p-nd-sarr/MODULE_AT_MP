class AddInfoComptableToDossierPrestationAvisTiers < ActiveRecord::Migration[5.2]
  def change
    add_column :dossier_prestation_avis_tiers, :traite_par_id, :integer
    add_column :dossier_prestation_avis_tiers, :traite_le, :date
  end
end
