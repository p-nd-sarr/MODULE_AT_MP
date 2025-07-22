class AddColumnsOpAndPaiementToAtDecomptes < ActiveRecord::Migration[5.2]
  def change
    add_column :at_decomptes, :paiement, :boolean, default: false
    add_reference :at_decomptes, :ordre_paiement, foreign_key: true
  end
end
