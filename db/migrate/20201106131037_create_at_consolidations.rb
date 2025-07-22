class CreateAtConsolidations < ActiveRecord::Migration[5.2]
  def change
    create_table :at_consolidations do |t|
      t.string :prenom, null: false
      t.string :nom, null: false
      t.date :date_naissance, null: false
      t.string :lieu_naissance
      t.string :numero_affiliation, null: false
      t.string :adresse
      t.string :telephone
      t.string :email
      t.string :workflow_state, :string
      t.string :soumis_par, :integer
      t.string :date_soumission, :datetime
      t.integer :mode_paiement
      t.string :compte_bancaire_nom_banque
      t.string :compte_bancaire_code_banque
      t.string :compte_bancaire_code_guichet
      t.string :compte_bancaire_numero_compte
      t.string :num_dossier
      t.text :motif
      t.integer :admin_banque_id
      t.boolean :etat_civil_demandeur_valide, default: false
      t.boolean :documents_valide,:boolean, default: false
      t.integer :taux_incapacite
      t.date :date_consolidation
      t.integer :soumis_par
      t.date :date_soumission
      t.integer :ajoute_par_id
      t.timestamps
    end
  end
end
