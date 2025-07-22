class CreateModifierModePaiement < ActiveRecord::Migration[5.2]
  def change
    create_table :modifier_mode_paiements do |t|
      t.references :allocataire, foreign_key: true
      t.string :numero_allocataire, null: false
      t.string :prenom, null: false
      t.string :nom, null: false
      t.integer :mode_paiement
      t.string :compte_bancaire_nom_banque
      t.string :compte_bancaire_code_banque
      t.string :compte_bancaire_code_guichet
      t.string :compte_bancaire_numero_compte
      t.date :date_soumission
      t.date :date_validation
      t.references :user, foreign_key: true
      t.integer :valide_par_id
      t.integer :ajoute_par_id
      t.datetime :traite_le
      t.integer :traite_par_id
      t.string :motif_rejet
      t.integer :etat, null: false, default: 1
    end
  end
end
