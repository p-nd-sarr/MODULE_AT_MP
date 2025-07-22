class AddColumnCaisseCafToPrestationExterieure < ActiveRecord::Migration[5.2]
  def change
    add_reference :prestation_exterieures, :admin_cities, foreign_key: true
  end
end
