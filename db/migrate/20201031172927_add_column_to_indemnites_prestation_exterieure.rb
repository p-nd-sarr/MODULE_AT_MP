class AddColumnToIndemnitesPrestationExterieure < ActiveRecord::Migration[5.2]
  def change
    add_reference :indemnites_prestation_exterieures, :prestation_exterieure, foreign_key: true, index: {name: :prestation_id}
  end
end