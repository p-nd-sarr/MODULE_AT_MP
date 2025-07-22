class CreateCips < ActiveRecord::Migration[5.2]
  def change
    create_table :cips do |t|
      t.string  :prenom
      t.string  :nom
      t.string  :demande_type
      t.datetime :date_creation
      t.integer :ajoute_par_id
      t.string  :nin,  unique: true
      t.string  :piece_identite
      t.text :observation
      t.timestamps
    end
  end
end
