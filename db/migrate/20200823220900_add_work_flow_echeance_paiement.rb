class AddWorkFlowEcheancePaiement < ActiveRecord::Migration[5.2]
  def change
    add_column :echeance_paiements, :workflow_state, :string
    add_column :echeance_paiements, :valider_le, :datetime
    add_column :echeance_paiements, :validation_par_id, :integer
    add_column :echeance_paiements, :traite_par_id, :integer
    add_column :echeance_paiements, :traite_le, :datetime
  end
end
