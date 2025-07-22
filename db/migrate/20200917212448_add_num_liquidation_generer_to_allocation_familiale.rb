class AddNumLiquidationGenererToAllocationFamiliale < ActiveRecord::Migration[5.2]
  def change
    add_column :allocation_familiales, :numero_liquidation_generer, :string
  end
end
