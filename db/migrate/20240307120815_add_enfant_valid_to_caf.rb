class AddEnfantValidToCaf < ActiveRecord::Migration[5.2]
  def change
    add_column :prestation_exterieures, :enfant_valid, :boolean
  end
end
