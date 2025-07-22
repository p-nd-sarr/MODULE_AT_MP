class AddInformationsToLiquidationRetraite < ActiveRecord::Migration[5.2]
  def change
    add_column :liquidation_retraites, :motif_remboursement, :string
    add_column :liquidation_retraites, :periode_remboursement, :string
    add_column :liquidation_retraites, :remboursement_cotisation, :boolean, default: false
  end
end
