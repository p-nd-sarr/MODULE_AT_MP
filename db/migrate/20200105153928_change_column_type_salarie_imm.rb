class ChangeColumnTypeSalarieImm < ActiveRecord::Migration[5.2]
  def change
    remove_column :salarie_immatriculations, :nationalite
    remove_column :salarie_immatriculations, :pays_delivrance
    remove_column :salarie_immatriculations, :ville_naissance
    remove_column :salarie_immatriculations, :pays
    remove_column :salarie_immatriculations, :nature_contrat
    remove_column :salarie_immatriculations, :profession
    remove_column :salarie_immatriculations, :convention_applicable


    add_column :salarie_immatriculations, :nationalite, :integer
    add_column :salarie_immatriculations, :pays_delivrance, :integer
    add_column :salarie_immatriculations, :ville_naissance, :integer
    add_column :salarie_immatriculations, :pays, :integer
    add_column :salarie_immatriculations, :nature_contrat, :integer
    add_column :salarie_immatriculations, :profession, :integer
    add_column :salarie_immatriculations, :convention_applicable, :integer

    add_column :salarie_immatriculations, :region, :integer
    add_column :salarie_immatriculations, :departement, :integer
    add_column :salarie_immatriculations, :arrondissement, :integer
    add_column :salarie_immatriculations, :commune, :integer
    add_column :salarie_immatriculations, :quartier, :integer

    add_column :salarie_immatriculations, :pays_naissance, :integer
  end
end
