class AddZoneAndRegionToLiquidationRetraite < ActiveRecord::Migration[5.2]
  def change
    add_column :liquidation_retraites, :zone, :integer
    add_reference :liquidation_retraites, :admin_region, foreign_key: true, null: true
  end
end
