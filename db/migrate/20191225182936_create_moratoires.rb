class CreateMoratoires < ActiveRecord::Migration[5.2]
  def change
    create_table :moratoires do |t|
      t.date :date_debut
      t.integer :nombre_echeance
      t.text  :commentaire
      t.date  :date_fin
      t.float  :premier_montant
      t.float  :dernier_montant
      t.float  :montant
      t.integer  :statut

      t.references :immatriculation, foreign_key: true

      t.timestamps
    end
  end
end
