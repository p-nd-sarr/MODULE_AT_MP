class RenameDemandeLiquidationFromDocumentLiquidationRetraite < ActiveRecord::Migration[5.2]
  def change
    rename_column :document_liquidation_retraites, :demande_liquidation_id, :liquidation_retraite_id
  end
end
