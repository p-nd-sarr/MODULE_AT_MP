class AddNumLiquidationToIcm < ActiveRecord::Migration[5.2]
  def change
    add_column :indemnite_conges_maternites, :numero_liquidation, :string
  end
end
