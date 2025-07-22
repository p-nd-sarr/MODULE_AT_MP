class AddColumnAdminAgenceToArretTravails < ActiveRecord::Migration[5.2]
  def change
    add_reference :arret_travails, :admin_agence
  end
end
