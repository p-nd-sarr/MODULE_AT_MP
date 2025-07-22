class AddAgencePaiementToModifierModePaiement < ActiveRecord::Migration[5.2]
  def change
    add_reference :modifier_mode_paiements, :admin_agence, foreign_key: true, null: true
  end
end
