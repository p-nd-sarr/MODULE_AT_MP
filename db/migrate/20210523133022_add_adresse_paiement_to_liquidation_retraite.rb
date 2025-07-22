class AddAdressePaiementToLiquidationRetraite < ActiveRecord::Migration[5.2]
  def change
    add_column :liquidation_retraites, :adresse_paiement, :string
  end
end
