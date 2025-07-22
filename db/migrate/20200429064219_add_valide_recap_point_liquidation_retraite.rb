class AddValideRecapPointLiquidationRetraite < ActiveRecord::Migration[5.2]
  def change
    add_column :liquidation_retraites, :recap_point_valide, :boolean, default: false
  end
end
