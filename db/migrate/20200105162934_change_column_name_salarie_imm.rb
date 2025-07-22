class ChangeColumnNameSalarieImm < ActiveRecord::Migration[5.2]
  def change
    remove_column :salarie_immatriculations, :nommere
    remove_column :salarie_immatriculations, :cadre
    add_column :salarie_immatriculations, :nom_mere, :string
    add_column :salarie_immatriculations, :est_cadre, :boolean
  end
end
