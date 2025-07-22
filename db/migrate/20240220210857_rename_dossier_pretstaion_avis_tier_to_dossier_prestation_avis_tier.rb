class RenameDossierPretstaionAvisTierToDossierPrestationAvisTier < ActiveRecord::Migration[5.2]
  def change
    rename_table :dossier_pretstaion_avis_tiers, :dossier_prestation_avis_tiers
  end
end
