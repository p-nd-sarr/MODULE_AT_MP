class CreateAscendantsSalaries < ActiveRecord::Migration[5.2]
  def change
    create_table :ascendants_salaries do |t|
      t.references :user, foreign_key: true
      t.references :conjoint, foreign_key: true

      t.string :numero_affiliation, null: false
      t.string :nom_salarie, null: false
      t.string :prenom_salarie, null: false

      t.string :prenom_mere, null: false
      t.string :nom_mere, null: false
      t.date :date_naissance_mere, null: false
      t.string :numero_piece_mere
      t.integer :type_piece_mere

      t.string :prenom_pere, null: false
      t.string :nom_pere, null: false
      t.date :date_naissance_pere, null: false
      t.string :numero_piece_pere
      t.integer :type_piece_pere

      t.timestamps
    end
  end
end
