class RenameMotifLiquidation < ActiveRecord::Migration[5.2]
  def change

    rename_column :liquidation_retraites, :motif_rejet, :motif
  end
end
