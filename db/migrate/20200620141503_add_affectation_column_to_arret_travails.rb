class AddAffectationColumnToArretTravails < ActiveRecord::Migration[5.2]
  def change
    add_column :arret_travails, :affecte_a, :string
    add_column :arret_travails, :affectation_type, :integer
  end
end
