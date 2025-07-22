class ChangeWorkflowColumnToDossierPrestation < ActiveRecord::Migration[5.2]
  def change
    rename_column :dossier_prestations, :workflow_state, :motif_retour
  end
end
