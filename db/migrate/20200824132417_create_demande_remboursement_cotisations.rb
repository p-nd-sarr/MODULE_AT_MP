class CreateDemandeRemboursementCotisations < ActiveRecord::Migration[5.2]
  def change
    create_table :demande_remboursement_cotisations do |t|
      t.references :user
      t.string :numero_affiliation, null: false
      t.string :prenom, null: false
      t.string :nom, null: false
      t.date :date_naissance, null: false
      t.string :lieu_naissance, null: false
      t.string :email
      t.string :adresse_reception_allocation
      t.string :adresse_domicile
      t.integer :mode_paiement
      t.string :compte_bancaire_nom_banque
      t.string :compte_bancaire_code_banque
      t.string :compte_bancaire_code_guichet
      t.string :compte_bancaire_numero_compte
      t.integer :motif_remboursement
      t.string :periode_remboursement
      t.boolean :etat_civil_demandeur_valide, default: false, null: false
      t.boolean :documents_valide, default: false, null: false
      t.boolean :remboursement_valide, default: false
      t.boolean :recap_remboursement_valide, default: false
      t.string :workflow_state
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
      t.string :num_dossier
      t.text :motif
      t.datetime :debut_periode
      t.datetime :fin_periode 
      t.timestamps
    end
  end
end
