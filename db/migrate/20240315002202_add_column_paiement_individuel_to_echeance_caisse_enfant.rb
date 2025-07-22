class AddColumnPaiementIndividuelToEcheanceCaisseEnfant < ActiveRecord::Migration[5.2]
  def change
    add_column :echeance_caisse_enfants, :paiement_individuel, :boolean, default: false
  end
end
