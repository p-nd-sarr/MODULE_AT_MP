class AddRegularisationPointageToOrdrePaiement < ActiveRecord::Migration[5.2]
  def change
    add_column :ordre_paiements, :regularisation_pointage_id, :integer, index: true
  end
end
