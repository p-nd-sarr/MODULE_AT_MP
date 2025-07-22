class AddNinToCaissePaiement < ActiveRecord::Migration[5.2]
  def change
    add_column :caisse_paiements, :nin, :string, limit: 50
  end
end
