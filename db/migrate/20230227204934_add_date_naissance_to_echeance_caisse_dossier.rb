class AddDateNaissanceToEcheanceCaisseDossier < ActiveRecord::Migration[5.2]
  def change
    add_column :echeance_caisse_dossiers, :date_naissance, :date
  end
end
