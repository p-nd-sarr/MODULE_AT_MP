class AddColumnPaysPrestationToPrestationExterieure < ActiveRecord::Migration[5.2]
  def change
    add_reference :prestation_exterieures, :admin_country,  foreign_key: true
  end
end
