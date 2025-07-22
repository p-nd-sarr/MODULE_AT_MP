class CreateAtAvis < ActiveRecord::Migration[5.2]
  def change
    create_table :at_avis do |t|
      t.text :description
      t.string :fait_par
      t.string :fait_par_profil
      t.references :arret_travail, foreign_key: true

      t.timestamps
    end
  end
end
