class AddAffectationLiquidationRetraite < ActiveRecord::Migration[5.2]
  def change
    add_column :liquidation_retraites, :affecter_le, :datetime, null: true
    add_column :liquidation_retraites, :affecter_id, :integer, null: true
  end
end
