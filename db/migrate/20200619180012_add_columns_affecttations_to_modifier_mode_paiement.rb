class AddColumnsAffecttationsToModifierModePaiement < ActiveRecord::Migration[5.2]
  def change
    add_column :modifier_mode_paiements, :affectation_allocataire, :integer
    add_column :modifier_mode_paiements, :affectation_allocataire_date, :datetime
  end
end
