class CreatePretAllocataireLignes < ActiveRecord::Migration[5.2]
  def change
    create_table :pret_allocataire_lignes do |t|
      t.float :montant
      t.float :montant_mensuel
      t.datetime :date_debut
      t.string :date_fin
      t.string :numero_allocataire
      t.integer :regime
      t.integer :pret_allocataire_id

      t.timestamps
    end
  end
end
