class AddworkflowModifierModePaiement < ActiveRecord::Migration[5.2]
  def change
    add_column :modifier_mode_paiements, :workflow_state, :string
    add_column :modifier_mode_paiements, :motif, :string
    add_column :modifier_mode_paiements, :instruit_par_id, :integer
    add_column :modifier_mode_paiements, :instruit_le, :datetime
    add_column :modifier_mode_paiements, :numero_dossier, :string
    add_column :modifier_mode_paiements, :etat_civil_demandeur_valide,:boolean, default: false
    add_column :modifier_mode_paiements, :documents_valide,:boolean, default: false
    add_column :modifier_mode_paiements, :recap_regularisation,:boolean, default: false
    add_timestamps :modifier_mode_paiements, null: false, default: -> { 'NOW()' }
  end
end
