class AddWorkflowToSuspensionAllocataire < ActiveRecord::Migration[5.2]
  def change
    add_column :suspension_allocataires, :workflow_state, :string
    add_column :suspension_allocataires, :verifie_par_id, :integer
    add_column :suspension_allocataires, :date_verification, :datetime
  end
end
