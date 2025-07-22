class AddIdentifiantToEcheanceCaisseEmployeurs < ActiveRecord::Migration[5.2]
  def change
    add_column :echeance_caisse_employeurs, :identifiant_mandataire, :string
  end
end
