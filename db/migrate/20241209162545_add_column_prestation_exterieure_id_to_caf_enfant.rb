class AddColumnPrestationExterieureIdToCafEnfant < ActiveRecord::Migration[5.2]
  def change
    add_reference :caf_enfants, :prestation_exterieure, foreign_key: true
  end
end
