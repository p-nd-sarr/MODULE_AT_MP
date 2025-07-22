class RemoveColumnsLiquidationRetraiteFrance < ActiveRecord::Migration[5.2]
  def change
    remove_column :liquidation_retraite_frances, :num_immatric_cfs
    remove_column :liquidation_retraite_frances, :num_immatric_ipres
  end
end
