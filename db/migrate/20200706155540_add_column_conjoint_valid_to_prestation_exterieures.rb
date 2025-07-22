class AddColumnConjointValidToPrestationExterieures < ActiveRecord::Migration[5.2]
  def change
    add_column :prestation_exterieures, :conjoint_valid, :boolean
  end
end
