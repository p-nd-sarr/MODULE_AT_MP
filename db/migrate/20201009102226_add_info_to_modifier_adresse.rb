class AddInfoToModifierAdresse < ActiveRecord::Migration[5.2]
  def change
    add_column :modifier_adresses, :modification_valide, :boolean, default: false
    add_column :modifier_adresses, :modification_soumis, :boolean, default: false
    add_column :modifier_adresses, :workflow_state, :string
    add_column :modifier_adresses, :motif, :string
    add_column :modifier_adresses, :numero_dossier, :string
    add_column :modifier_adresses, :etat_civil_demandeur_valide,:boolean, default: false
    add_column :modifier_adresses, :documents_valide,:boolean, default: false
 
  end
end
