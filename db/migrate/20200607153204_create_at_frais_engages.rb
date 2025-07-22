class CreateAtFraisEngages < ActiveRecord::Migration[5.2]
  def change
    create_table :at_frais_engages do |t|
      t.string :numero
      t.string :prenom
      t.string :nom
      t.string :montant
      t.string :date_liquidation
      t.string :nature
      t.integer :type_frais
      t.references :arret_travail, foreign_key: true

      t.timestamps
    end
  end
end
