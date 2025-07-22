class AddColumnRejetToDpAvisTier < ActiveRecord::Migration[5.2]
  def change
    add_column :dossier_prestation_avis_tiers, :retourner_par_id, :integer
    add_column :dossier_prestation_avis_tiers, :date_retour, :date
    add_column :dossier_prestation_avis_tiers, :motif_retour, :text
  end
end
