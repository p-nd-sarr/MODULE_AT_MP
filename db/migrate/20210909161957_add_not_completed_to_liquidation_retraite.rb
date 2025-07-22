class AddNotCompletedToLiquidationRetraite < ActiveRecord::Migration[5.2]
  def change
    add_column :liquidation_retraites, :not_completed, :boolean, default: false
    add_column :liquidation_retraites, :motif_not_completed, :integer
  end
end
