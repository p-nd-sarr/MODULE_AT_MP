class RenameValideFromEcheanceCaisseEnfant < ActiveRecord::Migration[5.2]
  def change
    rename_column :echeance_caisse_enfants, :valide, :document_valide
  end
end
