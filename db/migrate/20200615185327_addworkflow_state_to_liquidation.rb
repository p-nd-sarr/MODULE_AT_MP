class AddworkflowStateToLiquidation < ActiveRecord::Migration[5.2]
  def change
    add_column :liquidation_retraites, :workflow_state, :string
  end
end
