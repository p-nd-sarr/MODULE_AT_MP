class CreateUpdateGrappeFamiliales < ActiveRecord::Migration[5.2]
  def change
    create_table :update_grappe_familiales do |t|
      t.integer :conjoint_id
      t.integer :enfant_id
      t.string :num_affiliation
      t.string :prenom
      t.string :nom
      t.date :date_soumission
      t.date :date_deces
      t.string :lieu_deces
      t.date :date_validation
      t.integer :valide_par_id
      t.references :user, foreign_key: true
      t.integer :ajoute_par_id
      t.datetime :traite_le
      t.integer :traite_par_id
      t.string :motif_rejet
      t.integer :montant_paiement
      t.boolean :paiement
      t.integer :etat
      t.integer :trimestre
      t.integer :annee
      t.string :attachment
      t.string :num_dossier
      t.timestamps
    end
  end
end
