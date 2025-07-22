class AddRegMatriToLiquidationRetraiteFrance < ActiveRecord::Migration[5.2]
  def change
    add_column :liquidation_retraite_frances, :regime_matrimoniale, :integer
    add_column :liquidation_retraite_frances, :nombre_femmes, :integer
  end
end
