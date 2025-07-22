class AddColumnInfomationValidToPrestationExterieures < ActiveRecord::Migration[5.2]
  def change
    add_column :prestation_exterieures, :information_valid, :boolean
  end
end
