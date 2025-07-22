class AddColumnAjouteParToPrestationExterieure < ActiveRecord::Migration[5.2]
  def change
    add_column :prestation_exterieures, :ajoute_par_id, :integer
  end
end
