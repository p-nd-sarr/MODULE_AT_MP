class AddSoumisParToModifierModePaiement < ActiveRecord::Migration[5.2]
  def change
    add_column :modifier_mode_paiements, :soumis_par, :integer
  end
end
