class AddDateVersementToAvisTier < ActiveRecord::Migration[5.2]
  def change
    add_column :avis_tiers, :date_versement, :date
  end
end
