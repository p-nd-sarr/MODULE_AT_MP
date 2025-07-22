class AddSendToCaissePaiementToOrdrePaiement < ActiveRecord::Migration[5.2]
  def change
    add_column :ordre_paiements, :send_to_caisse_paiement, :boolean, default: false, null: false
  end
end
