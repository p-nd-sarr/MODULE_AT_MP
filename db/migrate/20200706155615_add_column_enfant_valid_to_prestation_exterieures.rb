class AddColumnEnfantValidToPrestationExterieures < ActiveRecord::Migration[5.2]
  def change
    remove_column :caf_enfants, :lien_parente, :string
    add_column :caf_enfants, :lien_parente, :integer
  end
end


