class AddColumnsOpAndPaiementToAtFraisEngages < ActiveRecord::Migration[5.2]
  def change
    add_column :at_frais_engages, :paiement, :boolean, default: false
    add_reference :at_frais_engages, :ordre_paiement, foreign_key: true
  end
end
