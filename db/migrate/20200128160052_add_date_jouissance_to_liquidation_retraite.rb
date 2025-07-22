class AddDateJouissanceToLiquidationRetraite < ActiveRecord::Migration[5.2]
  def change
    add_column :liquidation_retraites, :date_jouissance, :date
  end
end
