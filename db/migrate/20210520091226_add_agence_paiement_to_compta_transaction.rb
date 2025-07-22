class AddAgencePaiementToComptaTransaction < ActiveRecord::Migration[5.2]
  def change
    add_reference :compta_transactions, :admin_agence, foreign_key: true, null: true
  end
end
