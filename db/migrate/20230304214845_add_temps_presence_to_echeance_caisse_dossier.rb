class AddTempsPresenceToEcheanceCaisseDossier < ActiveRecord::Migration[5.2]
  def change
    add_column :echeance_caisse_dossiers, :temps_presence_mois1, :integer, default: 18
    add_column :echeance_caisse_dossiers, :temps_presence_mois2, :integer, default: 18
    add_column :echeance_caisse_dossiers, :temps_presence_mois3, :integer, default: 18
  end
end
