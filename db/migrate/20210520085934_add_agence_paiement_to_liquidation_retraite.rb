class AddAgencePaiementToLiquidationRetraite < ActiveRecord::Migration[5.2]
  def change
    add_reference :liquidation_retraites, :admin_agence, foreign_key: true, null: true
  end
end
