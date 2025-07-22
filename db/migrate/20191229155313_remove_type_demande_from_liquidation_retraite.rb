class RemoveTypeDemandeFromLiquidationRetraite < ActiveRecord::Migration[5.2]
  def change
    remove_column :liquidation_retraites, :type_demande
  end
end
