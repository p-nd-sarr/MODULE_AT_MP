class AddMotifRejetToLiquidationRetraite < ActiveRecord::Migration[5.2]
  def change
    add_column :liquidation_retraites, :motif_rejet, :text
  end
end
