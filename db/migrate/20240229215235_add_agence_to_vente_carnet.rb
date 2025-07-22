class AddAgenceToVenteCarnet < ActiveRecord::Migration[5.2]
  def change
    add_reference :at_vente_carnets, :admin_agence
  end
end
