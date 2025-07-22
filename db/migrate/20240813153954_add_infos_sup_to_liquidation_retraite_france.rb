class AddInfosSupToLiquidationRetraiteFrance < ActiveRecord::Migration[5.2]
  def change
    add_column :liquidation_retraite_frances, :affiliation, :boolean, :default => true
    add_column :liquidation_retraite_frances, :situation_matrimoniale, :integer


  end
end
