class AddColumnWorkflowStateToIndemnitesExterieure < ActiveRecord::Migration[5.2]
  def change
    add_column :indemnites_prestation_exterieures, :workflow_state_dt, :string
  end
end
