class ChangeDefaultColLiquidationRetFrance < ActiveRecord::Migration[5.2]
  def change
    change_column_default :liquidation_retraite_frances, :affiliation, false

  end
end
