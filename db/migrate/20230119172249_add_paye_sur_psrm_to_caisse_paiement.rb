class AddPayeSurPsrmToCaissePaiement < ActiveRecord::Migration[5.2]
  def change
    add_column :caisse_paiements, :paye_sur_psrm, :boolean, default: false, null: false
  end
end
