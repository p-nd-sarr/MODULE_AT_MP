class CreateSuspensionAllocataire < ActiveRecord::Migration[5.2]
  def change
    create_table :suspension_allocataires do |t|
      t.string :numero_allocataire
      t.string :prenom
      t.string :nom
      t.date :date_soumission
      t.integer :ajoute_par_id
      t.date :date_validation
      t.integer :valide_par_id
      t.string :motif_suspension
      t.integer :affectation_allocataire
      t.date :affectation_allocataire_date
      t.integer :duree_suspension
      t.integer :etat
      t.string :attachment
      t.string :motif_rejet
      t.datetime :traite_le
      t.integer :traite_par_id
      t.timestamps
    end
  end
end
