class AddColmnsToImmatriculation < ActiveRecord::Migration[5.2]
  def change
    add_column :immatriculations, :etat_civil_demandeur_valide, :boolean, null: false, default: false
    add_column :immatriculations, :representant_valide, :boolean, null: false, default: false
    add_column :immatriculations, :salarie_valide, :boolean, null: false, default: false
    add_column :immatriculations, :documents_valide, :boolean, null: false, default: false
    add_column :immatriculations, :etat, :integer, null: false, default: 1
    add_column :immatriculations, :date_soumission, :date

  end
end
