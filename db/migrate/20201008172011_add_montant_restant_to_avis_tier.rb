class AddMontantRestantToAvisTier < ActiveRecord::Migration[5.2]
  def change
    add_column :avis_tiers, :montant_restant, :float, default: 0, null: false
  end
end
