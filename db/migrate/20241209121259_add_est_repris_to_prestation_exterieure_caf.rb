class AddEstReprisToPrestationExterieureCaf < ActiveRecord::Migration[5.2]
  def change
    add_column :prestation_exterieures, :est_repris, :boolean, default: false
  end
end
