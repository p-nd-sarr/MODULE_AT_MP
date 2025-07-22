class CreateBaseReversionSalarie < ActiveRecord::Migration[5.2]
  def change
    create_table :base_reversion_salaries do |t|
      t.references :reversion_veuve_salarie, foreign_key: true, null: true
      t.string :prenom, null: false
      t.string :nom, null: false
      t.date :date_naissance, null: false
      t.string :lieu_naissance
      t.string :numero_affiliation, null: false
      t.string :adresse
      t.integer :mode_paiement
      t.string :compte_bancaire_nom_banque
      t.string :compte_bancaire_code_banque
      t.string :compte_bancaire_code_guichet
      t.string :compte_bancaire_numero_compte
      t.string :adresse_reception_allocation
      t.string :nom_tuteur
      t.string :prenom_tuteur
      t.datetime :traite_le
      t.integer :traite_par_id
      t.boolean :eligible, :boolean, default: false
      t.references :conjoint, foreign_key: true, null: true
      t.references :enfant, foreign_key: true, null: true
      t.datetime :date_soumis
      t.integer :ajoute_par_id
      t.date :ajouter_le
      t.integer :affecter_a
      t.date :affecter_le
      t.integer :instruit_par_id
      t.date :instruit_le
      t.integer :valider_par_id
      t.date :valider_le
      t.integer :affecter_salarie
      t.integer :type_ayant_droit
      t.string :numero_dossier, null: false
      t.integer :etat, null: false, default: 0
      t.timestamps
     
    end
  end
end
