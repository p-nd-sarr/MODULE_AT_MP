class AddAgenceCreationToModifierModePaiement < ActiveRecord::Migration[5.2]
  def change
    add_column :modifier_mode_paiements, :agence_creation_id, :integer
  end
end
