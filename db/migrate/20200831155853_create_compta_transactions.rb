class CreateComptaTransactions < ActiveRecord::Migration[5.2]
  def change
    create_table :compta_transactions do |t|
      t.references :dossier, polymorphic: true, null: false, index: { name: 'index_compta_transactions_on_dr_type_and_dr_id' }
      t.string :code_operation, null: false
      t.string :branche, null: false
      t.integer :legal_entity_id, null: false
      t.string :code_classe_evenement, null: false, default: 'LIQUIDATION'

      t.string :code_agence_liquidation
      t.string :numero_allocataire, null: false
      t.string :nom, null: false
      t.string :prenom, null: false
      t.string :adresse
      t.string :code_banque_allocataire
      t.string :numero_compte_allocataire

      t.date :date_debut_periode
      t.date :date_fin_periode
      t.float :montant, null: false
      t.string :code_devise, null: false, default: 'XOF', limit: 3

      t.integer :statut, null: false, default: 0

      t.timestamps
    end
  end
end
