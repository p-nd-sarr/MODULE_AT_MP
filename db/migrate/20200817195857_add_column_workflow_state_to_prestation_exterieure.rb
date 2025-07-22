class AddColumnWorkflowStateToPrestationExterieure < ActiveRecord::Migration[5.2]
  def change
    add_column :prestation_exterieures, :workflow_state, :string
  end
end
