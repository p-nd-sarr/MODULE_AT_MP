class NullableDossierFromOrdrePaiement < ActiveRecord::Migration[5.2]
  def change
    change_column_null :ordre_paiements, :dossier_id, true
    change_column_null :ordre_paiements, :dossier_type, true
  end
end
