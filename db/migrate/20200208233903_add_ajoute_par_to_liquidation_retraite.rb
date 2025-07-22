class AddAjouteParToLiquidationRetraite < ActiveRecord::Migration[5.2]
  def change
    add_column :liquidation_retraites, :ajoute_par_id, :integer
  end
end
