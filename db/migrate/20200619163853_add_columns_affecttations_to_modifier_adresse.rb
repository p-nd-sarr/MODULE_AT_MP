class AddColumnsAffecttationsToModifierAdresse < ActiveRecord::Migration[5.2]
  def change
    add_column :modifier_adresses, :affectation_allocataire, :integer
    add_column :modifier_adresses, :affectation_allocataire_date, :datetime
  end
end
