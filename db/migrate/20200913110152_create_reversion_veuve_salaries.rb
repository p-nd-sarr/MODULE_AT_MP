class CreateReversionVeuveSalaries < ActiveRecord::Migration[5.2]
  def change
    create_table :reversion_veuve_salaries do |t|
      t.string :numero_dossier
      t.string :numero_affiliation, null: false
      t.string :nom, null: false
      t.string :prenom, null: false
      t.string :conjoints_id, array: true, default: []
      t.string :enfants_id, array: true, default: []
      t.date :date_deces, null: false
      t.date :date_cessation_activite, null: false
      t.date :date_naissance, null: false
      t.boolean :etat_civil_demandeur_valide, default: false, null: false
      t.boolean :documents_valide, default: false, null: false
      t.boolean :carriere_valide, default: false, null: false
      t.boolean :recap_point_valide, default: false, null: false
      t.boolean :epouses_valide, default: false, null: false
      t.boolean :enfants_valide, default: false, null: false
      t.datetime :valider_le
      t.integer :valider_par_id
      t.integer :ajouter_par_id
      t.integer :instruit_par_id
      t.datetime :instruit_le
      t.datetime :affecter_le
      t.datetime :traite_le
      t.integer :traite_par_id
      t.integer :affectation_salarie
      t.datetime :affectation_salarie_date
      t.datetime :affectation_allocataire_date
      t.integer :affectation_allocataire
      t.date :date_soumission
      t.date :ajouter_le
      t.string :num_dossier
      t.text :motif
      t.datetime :debut_periode
      
      t.string :workflow_state
      t.timestamps
    end
  end
end
