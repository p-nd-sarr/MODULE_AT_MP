class CreatePretAllocataires < ActiveRecord::Migration[5.2]
  def change
    create_table :pret_allocataires do |t|
      t.string :numero_allocataire
      t.integer :type_pret
      t.integer :duree_mois
      t.string :commentaire
      t.integer :regime_id
      t.date :date_paiement
      t.date :date_debut
      t.date :date_fin
      t.float :montant
      t.integer :etat
      t.date :validation_date
      t.integer :validation_id
      t.integer :ajouter_par_id

      t.timestamps
    end
  end
end
