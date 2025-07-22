class AddMotifVirementToModifierModePaiement < ActiveRecord::Migration[5.2]
  def change
    add_column :modifier_mode_paiements, :motif_virement, :integer
  end
end
