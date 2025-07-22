class AddAttributesToArretTravailGeds < ActiveRecord::Migration[5.2]
  def change
    add_column :arret_travail_geds, :nature_accident, :integer
    add_column :arret_travail_geds, :situation_matrimoniale_salarie, :integer
    add_column :arret_travail_geds, :incapacite_permanente, :integer
    add_column :arret_travail_geds, :consequence_accident_travail, :integer
    add_column :arret_travail_geds, :type_declaration, :integer
  end
end