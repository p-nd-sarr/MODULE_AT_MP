class AddinfoToDossierPrestationAvisTier < ActiveRecord::Migration[5.2]
  def change
    add_column :dossier_prestation_avis_tiers, :nature_avis, :integer
    add_column :dossier_prestation_avis_tiers, :motif, :text
    add_column :dossier_prestation_avis_tiers, :trimestre, :integer
    add_column :dossier_prestation_avis_tiers, :annee, :integer
    add_column :dossier_prestation_avis_tiers, :volet_post, :integer
    add_column :dossier_prestation_avis_tiers, :volet_pre, :integer
    add_column :dossier_prestation_avis_tiers, :conjoint_id, :integer
    add_column :dossier_prestation_avis_tiers, :enfant_id, :integer
    add_column :dossier_prestation_avis_tiers, :numero_liquidation, :string
    add_column :dossier_prestation_avis_tiers, :date_liquidation, :date
  end
end
