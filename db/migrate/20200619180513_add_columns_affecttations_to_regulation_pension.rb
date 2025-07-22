class AddColumnsAffecttationsToRegulationPension < ActiveRecord::Migration[5.2]
  def change
    add_column :regulation_pensions, :affectation_allocataire, :integer
    add_column :regulation_pensions, :affectation_allocataire_date, :datetime
  end
end
