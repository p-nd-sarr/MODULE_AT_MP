class CreateCaissePaiements < ActiveRecord::Migration[5.2]
  def change
    create_table :caisse_paiements do |t|
      t.string :numero_ordre, limit: 20, index: true
      t.string :numero_allocataire, limit: 30, index: true
      t.string :ipres_ancien_matric, limit: 30, index: true
      t.string :prenom, index: true
      t.string :nom, index: true
      t.integer :source, index: true
      t.integer :mode_paiement, index: true
      t.string :details
      t.float :montant, null: false
      t.integer :etat, null: false, default: 1
      t.integer :annee
      t.integer :periode
      t.integer :numero_periode
      t.references :echeance_paiement, foreign_key: false, null: true
      t.references :compta_transaction, foreign_key: false, null: true
      t.datetime :date_paiement
      t.references :user, foreign_key: false, null: true

      t.timestamps
    end
  end
end
