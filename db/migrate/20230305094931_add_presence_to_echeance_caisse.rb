class AddPresenceToEcheanceCaisse < ActiveRecord::Migration[5.2]
  def change
    add_column :echeance_caisse_dossiers, :absence_justifie_mois1, :boolean, default: false
    add_column :echeance_caisse_dossiers, :absence_justifie_mois2, :boolean, default: false
    add_column :echeance_caisse_dossiers, :absence_justifie_mois3, :boolean, default: false

    add_column :echeance_caisse_dossiers, :motif_absence_mois1, :string
    add_column :echeance_caisse_dossiers, :motif_absence_mois2, :string
    add_column :echeance_caisse_dossiers, :motif_absence_mois3, :string
  end
end
