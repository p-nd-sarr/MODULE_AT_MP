class AddOrdrePaiementRegulariseToOrdrePaiement < ActiveRecord::Migration[5.2]
  def change
    add_column :ordre_paiements, :ordre_paiement_regularise_id, :integer
  end
end
