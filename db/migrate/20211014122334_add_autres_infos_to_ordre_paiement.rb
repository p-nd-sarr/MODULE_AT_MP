class AddAutresInfosToOrdrePaiement < ActiveRecord::Migration[5.2]
  def change
    add_column :ordre_paiements, :motif_impaye, :string
    add_column :ordre_paiements, :impaye_ajoute_le, :datetime
    add_column :ordre_paiements, :impaye_ajoute_par_id, :integer
  end
end
