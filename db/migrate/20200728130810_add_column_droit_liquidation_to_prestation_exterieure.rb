class AddColumnDroitLiquidationToPrestationExterieure < ActiveRecord::Migration[5.2]
  def change
    add_column :prestation_exterieures, :droit_liquidation, :integer
  end
end
