class RemoveColumnCafEnfantIdFromIpex < ActiveRecord::Migration[5.2]
  def change
    remove_column :indemnites_prestation_exterieures, :caf_enfant_id
  end
end
