class AddAjouteParToAtFraisEngages < ActiveRecord::Migration[5.2]
  def change
    add_column :at_frais_engages, :ajoute_par_id, :integer
    add_column :at_frais_engages, :validation_comptable_par, :integer
    add_column :at_frais_engages, :validation_medecin_conseil_par, :integer
    add_column :at_frais_engages, :validation_par, :integer
    add_column :at_frais_engages, :liquide_par, :integer
    add_column :at_frais_engages, :motif_rejet, :text
    add_column :at_frais_engages, :rejete_par, :integer
    add_column :at_frais_engages, :validation_medecin_obligatoire, :boolean, default: false
    add_column :at_frais_engages, :date_rejet, :datetime
    add_column :at_frais_engages, :active_par, :integer
    add_column :at_frais_engages, :date_activation, :datetime
    
  end
end
