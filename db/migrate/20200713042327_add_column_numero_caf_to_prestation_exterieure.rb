class AddColumnNumeroCafToPrestationExterieure < ActiveRecord::Migration[5.2]
  def change
    add_column :prestation_exterieures, :numero_caf, :integer
  end
end
