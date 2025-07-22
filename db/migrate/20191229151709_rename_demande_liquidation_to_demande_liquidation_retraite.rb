class RenameDemandeLiquidationToDemandeLiquidationRetraite < ActiveRecord::Migration[5.2]
  def change
    rename_table :liquidation_retraites, :demande_liquidation_retraites
  end
end
