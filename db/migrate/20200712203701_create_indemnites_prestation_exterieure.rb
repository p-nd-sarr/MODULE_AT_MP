class CreateIndemnitesPrestationExterieure < ActiveRecord::Migration[5.2]
  def change
    create_table :indemnites_prestation_exterieures do |t|

      t.references :caf_enfant, foreign_key: true
      t.integer :montant
      t.timestamps
    end
  end
end
