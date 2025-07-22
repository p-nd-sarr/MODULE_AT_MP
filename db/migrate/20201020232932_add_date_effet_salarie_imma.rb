class AddDateEffetSalarieImma < ActiveRecord::Migration[5.2]
  def change
    add_column :salarie_immatriculations, :date_effet_cadre, :date
  end
end