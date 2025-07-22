class AddAffecteParToModifierModePaiement < ActiveRecord::Migration[5.2]
  def change
    add_column :modifier_mode_paiements, :affecte_par_id, :integer
  end
end
