class AddPeriodesRemboursementToLiquidationRetraite < ActiveRecord::Migration[5.2]
  def change
    add_column :liquidation_retraites, :debut_periode, :date
    add_column :liquidation_retraites, :fin_periode, :date
  end
end
