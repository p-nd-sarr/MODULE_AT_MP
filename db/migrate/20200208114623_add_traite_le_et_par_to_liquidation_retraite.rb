class AddTraiteLeEtParToLiquidationRetraite < ActiveRecord::Migration[5.2]
  def change
    add_column :liquidation_retraites, :traite_le, :datetime, null: true
    add_column :liquidation_retraites, :traite_par_id, :integer, null: true
  end
end
