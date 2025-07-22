class AddColumnIndemniteValidToPrestationExterieures < ActiveRecord::Migration[5.2]
  def change
    add_column :prestation_exterieures, :indemnite_valid, :boolean
  end
end
