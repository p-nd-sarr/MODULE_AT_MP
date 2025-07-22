class AddDatePaiementToAllocations < ActiveRecord::Migration[5.2]
  def change
    add_column :indemnite_conges_maternites, :date_paiement, :datetime
    add_column :indemnite_conges_maternites, :date_liquidation, :datetime

    add_column :allocation_familiales, :date_paiement, :datetime
    add_column :allocation_familiales, :date_liquidation, :datetime

    add_column :allocation_postnatales, :date_paiement, :datetime
    add_column :allocation_postnatales, :date_liquidation, :datetime

    add_column :allocation_prenatales, :date_paiement, :datetime
    add_column :allocation_prenatales, :date_liquidation, :datetime

  end
end
