class AddDateAffectationToRenteFamille < ActiveRecord::Migration[5.2]
  def change
    add_column :at_rente_familles, :date_affectation, :date
    add_column :at_rente_familles, :affectation_technicien, :integer
    add_column :at_rente_familles, :conjoints_id, :string, array: true, default: []
    add_column :at_rente_familles, :enfants_id, :string, array: true, default: []
  end
end
