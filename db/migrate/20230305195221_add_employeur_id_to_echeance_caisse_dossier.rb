class AddEmployeurIdToEcheanceCaisseDossier < ActiveRecord::Migration[5.2]
  def change
    add_reference :echeance_caisse_dossiers, :echeance_caisse_employeur, foreign_key: true, index: { name: 'idx_ecd1' }
  end
end
