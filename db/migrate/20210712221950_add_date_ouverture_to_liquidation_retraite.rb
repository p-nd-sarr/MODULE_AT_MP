class AddDateOuvertureToLiquidationRetraite < ActiveRecord::Migration[5.2]
  def change
    add_column :liquidation_retraites, :date_ouverture, :datetime
    LiquidationRetraite.all.each { |l| l.date_ouverture = l.created_at; l.save }
  end
end
