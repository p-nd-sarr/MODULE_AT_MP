class ChangeColumnNameSalarieImm2 < ActiveRecord::Migration[5.2]
  def change

    remove_column :salarie_immatriculations, :arrondissement

    add_column :salarie_immatriculations, :arondissement, :integer

  end
end
