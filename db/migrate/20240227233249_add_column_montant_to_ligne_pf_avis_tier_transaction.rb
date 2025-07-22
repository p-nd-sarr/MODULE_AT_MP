class AddColumnMontantToLignePfAvisTierTransaction < ActiveRecord::Migration[5.2]
  def change
    add_column :ligne_pf_avis_tier_transactions, :montant_paye, :float
  end
end
