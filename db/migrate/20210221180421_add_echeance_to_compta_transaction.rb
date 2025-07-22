class AddEcheanceToComptaTransaction < ActiveRecord::Migration[5.2]
  def change
    add_reference :compta_transactions, :echeance_paiement, foreign_key: true, null: true
  end
end
