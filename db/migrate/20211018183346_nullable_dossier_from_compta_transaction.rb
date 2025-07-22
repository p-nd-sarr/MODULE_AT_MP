class NullableDossierFromComptaTransaction < ActiveRecord::Migration[5.2]
  def change
    change_column_null :compta_transactions, :dossier_id, true
    change_column_null :compta_transactions, :dossier_type, true
  end
end
