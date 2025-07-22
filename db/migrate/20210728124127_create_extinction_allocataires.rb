class CreateExtinctionAllocataires < ActiveRecord::Migration[5.2]
  def change
    create_table :extinction_allocataires do |t|
      t.string :numero_allocataire
      t.date :date_soumission
      t.integer :ajoute_par_id
      t.date :date_validation
      t.integer :valide_par_id
      t.string :motif_extinction
      t.integer :affectation_allocataire
      t.date :affectation_allocataire_date
      t.integer :etat
      t.string :motif_rejet
      t.datetime :traite_le
      t.integer :traite_par_id
      t.string :workflow_state
      t.integer :verifie_par_id
      t.datetime :date_verification
      t.boolean :information_valide
      t.boolean :document_valide
      t.timestamps
    end
  end
end
