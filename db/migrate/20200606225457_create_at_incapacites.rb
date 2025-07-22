class CreateAtIncapacites < ActiveRecord::Migration[5.2]
  def change
    create_table :at_incapacites do |t|
      t.date :date_debut
      t.date :date_fin
      t.integer :nombre_jour
      t.integer :nombre_heure
      t.references :arret_travail, foreign_key: true

      t.timestamps
    end
  end
end
