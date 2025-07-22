class AddImpayeParToCaissePaiement < ActiveRecord::Migration[5.2]
  def change
    add_column :caisse_paiements, :marquee_impayee_par_id, :integer
    add_column :caisse_paiements, :marquee_impayee_le, :datetime
  end
end
