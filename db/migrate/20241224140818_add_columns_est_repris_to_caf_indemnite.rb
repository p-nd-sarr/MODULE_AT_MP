class AddColumnsEstReprisToCafIndemnite < ActiveRecord::Migration[5.2]
  def change
    add_column :indemnites_prestation_exterieures, :est_repris, :boolean, :default => false
    add_column :indemnites_prestation_exterieures, :paiement, :boolean, :default => false
  end
end
