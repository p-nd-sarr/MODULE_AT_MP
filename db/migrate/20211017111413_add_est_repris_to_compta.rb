class AddEstReprisToCompta < ActiveRecord::Migration[5.2]
  def change
    add_column :ordre_paiements, :est_repris, :boolean, default: false, null: false
    add_column :compta_transactions, :est_repris, :boolean, default: false, null: false
    add_column :echeance_paiements, :est_repris, :boolean, default: false, null: false
  end
end
