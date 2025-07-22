class AddTypeRetraiteToLiquidationRetraite < ActiveRecord::Migration[5.2]
  def change
    add_column :liquidation_retraites, :type_retraite, :integer, null: false, default: 1
  end
end
