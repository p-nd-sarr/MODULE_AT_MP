class CreateRevisionPensions < ActiveRecord::Migration[5.2]
  def change
    create_table :revision_pensions do |t|
      t.integer :type_motif
      t.string :numero_affiliation, null: false
      t.string :numero_allocataire
      t.string :numero_dossier
      t.integer :etat
      t.datetime :ajouter_le
      t.integer :ajouter_par_id
      t.datetime :traite_le
      t.integer :traite_par_id
      t.datetime :afecter_allocataire_le
      t.integer :affecter_allocataire
      t.datetime :afecter_salarie_le
      t.integer :affecter_salarie
      t.integer :allocation_id
      t.datetime :date_reception
      t.string :commentaire
      t.string :motif
      t.datetime :date_soumission
      t.string :workflow_state

      t.timestamps
    end
  end
end
