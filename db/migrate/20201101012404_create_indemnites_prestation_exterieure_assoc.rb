class CreateIndemnitesPrestationExterieureAssoc < ActiveRecord::Migration[5.2]
  def change
    create_table :indemnites_prestation_exterieure_assocs do |t|
      t.references :indemnites_prestation_exterieure, index: {name: :indemnite_id}
      t.references :caf_enfant

      t.timestamps
    end
  end
end
