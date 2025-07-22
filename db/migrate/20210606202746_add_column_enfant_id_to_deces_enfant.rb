class AddColumnEnfantIdToDecesEnfant < ActiveRecord::Migration[5.2]
  def change
    add_column :admin_deces_enfants, :enfant_id, :bigint
  end
end
