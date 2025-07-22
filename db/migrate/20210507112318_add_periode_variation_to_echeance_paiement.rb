class AddPeriodeVariationToEcheancePaiement < ActiveRecord::Migration[5.2]
  def change
    add_column :echeance_paiements, :periode_variation_debut, :datetime
    add_column :echeance_paiements, :periode_variation_fin, :datetime
  end
end
