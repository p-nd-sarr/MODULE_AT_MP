class CreateAvisTiers < ActiveRecord::Migration[5.2]
  def change
    create_table :avis_tiers do |t|
      t.string :numero_dossier
      t.integer :type_operation
      t.float :montant
      t.float :montant_mensuel
      t.datetime :date_debut
      t.string :date_fin
      t.integer :nombre_echeance
      t.string :numero_allocataire
      t.string :commentaire
      t.integer :etat
      t.datetime :valider_le
      t.integer :valider_par_id
      t.integer :ajouter_par_id
      t.integer :gest_allocataire_id
      t.datetime :affecter_le
      t.datetime :traite_le

      t.timestamps
    end
  end
end
