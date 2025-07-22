class AddWorkflowStateToDossierPrestation < ActiveRecord::Migration[5.2]
  def change
    add_column :dossier_prestations, :workflow_state, :string
  end
end
