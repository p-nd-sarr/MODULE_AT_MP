class WorkflowStateToArretTravails < ActiveRecord::Migration[5.2]
  def change
    add_column :arret_travails, :workflow_state, :string
    add_column :arret_travails, :soumis_par, :integer
    add_column :arret_travails, :date_soumission, :datetime
    add_column :arret_travails, :motif, :string
    add_column :arret_travails, :instruit_par_id, :integer
    add_column :arret_travails, :instruit_le, :datetime
    add_column :arret_travails, :valider_le, :datetime
    add_column :arret_travails, :valider_par_id, :integer
    add_column :arret_travails, :traite_par_id, :integer
    add_column :arret_travails, :traite_le, :datetime
    add_column :arret_travails, :affectation_at, :integer
    add_column :arret_travails, :affectation_date, :datetime
    add_column :arret_travails, :ajoute_par_id, :integer
  end
end
