class AddColumnStatusToPfAvisTier < ActiveRecord::Migration[5.2]
  def change
    add_column :dossier_prestation_avis_tiers, :status, :integer, default: 2
  end
end
