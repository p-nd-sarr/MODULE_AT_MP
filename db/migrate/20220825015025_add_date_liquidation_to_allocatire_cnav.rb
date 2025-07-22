class AddDateLiquidationToAllocatireCnav < ActiveRecord::Migration[5.2]
  def change
    add_column :allocataire_cnavs, :date_liquidation, :datetime
  end
end
