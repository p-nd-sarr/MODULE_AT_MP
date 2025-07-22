class AddConsequenceAtColumnToArretTravails < ActiveRecord::Migration[5.2]
  def change
    add_column :arret_travails, :consequence_accident_travail, :integer
    add_column :arret_travails, :date_du_deces, :date
    add_column :arret_travails, :raison_absence_constat, :string
    add_column :arret_travails, :raison_sociale_assureur, :string
    add_column :arret_travails, :nom_assureur, :string
    add_column :arret_travails, :adresse_assureur, :string
    add_column :arret_travails, :numero_police_assurance, :string
    add_column :arret_travails, :incapacite_permanente, :integer
  end
end
