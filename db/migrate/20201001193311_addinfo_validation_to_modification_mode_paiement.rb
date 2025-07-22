class AddinfoValidationToModificationModePaiement < ActiveRecord::Migration[5.2]
  def change
    add_column :modifier_mode_paiements, :modification_valide, :boolean, default: false
    add_column :modifier_mode_paiements, :modification_soumis, :boolean, default: false
  end
end
