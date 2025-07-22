class CreateAttestations < ActiveRecord::Migration[5.2]
  def change
    create_table :attestations do |t|
      t.string :titre
      t.string :url
      t.integer :etat, default: 0
      t.string :message
      t.bigint :user_id

      t.timestamps
    end
  end
end
