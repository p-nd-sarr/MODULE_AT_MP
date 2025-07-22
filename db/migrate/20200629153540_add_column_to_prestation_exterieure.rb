class AddColumnToPrestationExterieure < ActiveRecord::Migration[5.2]
  def change
    add_column :prestation_exterieures, :type_piece, :integer
  end
end
