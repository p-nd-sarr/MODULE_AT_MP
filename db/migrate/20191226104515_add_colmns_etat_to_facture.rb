class AddColmnsEtatToFacture < ActiveRecord::Migration[5.2]
  def change
    add_column :factures, :statut, :integer, default: 0
    add_column :factures, :date_paiement, :date

    add_column :factures, :moratoire_id, :bigint



  end
end
