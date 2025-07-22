class AtSalaires < ActiveRecord::Migration[5.2]
  def change
    create_table :at_salaires do |t|
      t.references :arret_travail, foreign_key: true
      t.integer :mois
      t.integer :montant
    end
  end
end
