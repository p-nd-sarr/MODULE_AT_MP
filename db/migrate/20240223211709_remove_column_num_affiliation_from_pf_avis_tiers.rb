class RemoveColumnNumAffiliationFromPfAvisTiers < ActiveRecord::Migration[5.2]
  def change
    remove_column :dossier_prestation_avis_tiers, :num_affiliation
  end
end
