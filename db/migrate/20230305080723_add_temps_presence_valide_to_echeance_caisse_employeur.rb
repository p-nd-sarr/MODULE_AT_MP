class AddTempsPresenceValideToEcheanceCaisseEmployeur < ActiveRecord::Migration[5.2]
  def change
    add_column :echeance_caisse_employeurs, :temps_presence_valide, :boolean, default: false
  end
end
