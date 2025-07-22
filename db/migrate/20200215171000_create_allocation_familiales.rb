class CreateAllocationFamiliales < ActiveRecord::Migration[5.2]
  def change
    create_table :allocation_familiales do |t|
      t.references :dossier_prestation, foreign_key: true
      t.references :enfant, foreign_key: true
      t.date :date_soumission
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

      t.timestamps
    end
  end
end
