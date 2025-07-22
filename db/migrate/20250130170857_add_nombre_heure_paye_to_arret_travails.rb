class AddNombreHeurePayeToArretTravails < ActiveRecord::Migration[5.2]
  def change
    add_column :arret_travails, :nombre_heure_paye, :integer
  end
end
