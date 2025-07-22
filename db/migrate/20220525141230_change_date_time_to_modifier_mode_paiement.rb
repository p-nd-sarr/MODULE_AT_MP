class ChangeDateTimeToModifierModePaiement < ActiveRecord::Migration[5.2]
  def change
    change_column :modifier_mode_paiements, :date_soumission, :datetime
    change_column :modifier_mode_paiements, :date_validation, :datetime
  end
end
