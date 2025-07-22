class AddColumnNameImmatriculation < ActiveRecord::Migration[5.2]
  def change
    add_column :immatriculations, :effectif_employe, :integer
    add_column :immatriculations, :effectif_cadre, :integer
    add_column :immatriculations, :embauche_cadre, :date
    add_column :immatriculations, :embauche_employer, :date

  end
end
