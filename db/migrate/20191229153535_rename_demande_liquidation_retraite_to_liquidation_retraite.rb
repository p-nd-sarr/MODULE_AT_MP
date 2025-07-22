class RenameDemandeLiquidationRetraiteToLiquidationRetraite < ActiveRecord::Migration[5.2]
  def change
    rename_table :demande_liquidation_retraites, :liquidation_retraites
  end
end
