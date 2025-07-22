class AddPaiementToAllocationPrenatale < ActiveRecord::Migration[5.2]
  def change
    add_column :allocation_prenatales, :paiement, :boolean
    add_column :allocation_prenatales, :montant_paiement, :integer

  end
end
