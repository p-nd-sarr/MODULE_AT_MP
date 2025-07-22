class AddWorkflowToRegularisationPension < ActiveRecord::Migration[5.2]
  def change
    add_column :regularisation_pensions, :workflow_state, :string
    add_column :regularisation_pensions, :motif, :string
    add_column :regularisation_pensions, :instruit_par_id, :integer
    add_column :regularisation_pensions, :instruit_le, :datetime
    add_column :regularisation_pensions, :numero_dossier, :string
    add_column :regularisation_pensions, :etat_civil_demandeur_valide,:boolean, default: false
    add_column :regularisation_pensions, :documents_valide,:boolean, default: false
    add_column :regularisation_pensions, :recap_regularisation,:boolean, default: false
    add_timestamps :regularisation_pensions, null: false, default: -> { 'NOW()' }
  end
end
