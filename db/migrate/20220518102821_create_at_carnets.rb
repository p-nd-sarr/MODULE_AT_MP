class CreateAtCarnets < ActiveRecord::Migration[5.2]
  def change
    create_table :at_carnets do |t|
      t.string :numero_carnet
      t.integer :arret_travail_id
      t.string :numero_employeur
      t.string :raison_sociale
      t.datetime :date_achat

      t.timestamps
    end
  end
end
