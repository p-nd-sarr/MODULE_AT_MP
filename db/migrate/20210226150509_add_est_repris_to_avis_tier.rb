class AddEstReprisToAvisTier < ActiveRecord::Migration[5.2]
  def change
    add_column :avis_tiers, :est_repris, :boolean, default: false
  end
end
