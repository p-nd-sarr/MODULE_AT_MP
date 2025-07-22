class AddAjouteParAtDecompte < ActiveRecord::Migration[5.2]
  def change
    add_column :at_decomptes, :ajoute_par_id, :integer
    add_column :at_decomptes, :validation_comptable_par, :integer
    add_column :at_decomptes, :validation_medecin_conseil_par, :integer
    add_column :at_decomptes, :validation_par, :integer
    add_column :at_decomptes, :liquide_par, :integer
    add_column :at_decomptes, :motif_rejet, :text
    add_column :at_decomptes, :rejete_par, :integer
    add_column :at_decomptes, :validation_medecin_obligatoire, :boolean, default: false
    add_column :at_decomptes, :date_rejet, :datetime
  end
end
