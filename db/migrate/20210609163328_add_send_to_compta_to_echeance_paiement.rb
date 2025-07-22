class AddSendToComptaToEcheancePaiement < ActiveRecord::Migration[5.2]
  def change
    add_column :echeance_paiements, :send_to_compta, :boolean, null: false, default: false
  end
end
