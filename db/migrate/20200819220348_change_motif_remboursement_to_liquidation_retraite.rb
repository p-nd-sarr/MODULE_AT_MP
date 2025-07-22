class ChangeMotifRemboursementToLiquidationRetraite < ActiveRecord::Migration[5.2]
  def change
    change_column :liquidation_retraites, :motif_remboursement, :integer, using: 'motif_remboursement::integer'
  end
end
