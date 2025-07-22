class Participants < ActiveRecord::Migration[5.2]
  def change
    create_table :participants do |t|
      t.string :matric, null: false, index: true
      t.string :ipres_ancien_matric, index: true
      t.string :css_ancien_matric, index: true
      t.string :prenom, index: true
      t.string :nom, index: true
      t.string :type_piece
      t.string :numero_piece, index: true
      t.text :profession
      t.string :emploi
      t.string :regime
      t.string :addr
      t.string :phone
      t.date :date_naissance
      t.string :genre

      t.timestamps null: false
    end
  end
end
