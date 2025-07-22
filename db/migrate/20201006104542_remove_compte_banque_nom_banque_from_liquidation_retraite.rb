class RemoveCompteBanqueNomBanqueFromLiquidationRetraite < ActiveRecord::Migration[5.2]
  def change
    remove_column :liquidation_retraites, :compte_bancaire_nom_banque, :string
  end
end
