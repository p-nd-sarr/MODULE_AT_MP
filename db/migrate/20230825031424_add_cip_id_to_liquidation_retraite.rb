class AddCipIdToLiquidationRetraite < ActiveRecord::Migration[5.2]
  def change
    add_column :liquidation_retraites, :cip_id, :string
  end
end
