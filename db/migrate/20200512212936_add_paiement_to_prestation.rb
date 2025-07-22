class AddPaiementToPrestation < ActiveRecord::Migration[5.2]
  def self.up
    add_column :allocation_prenatales, :paiement_id, :integer
    add_column :allocation_postnatales, :paiement_id, :integer
    add_column :allocation_familiales, :paiement_id, :integer

    AllocationPrenatale.where(paiement: nil).update_all(paiement: false)
    AllocationPostnatale.where(paiement: nil).update_all(paiement: false)
    AllocationFamiliale.where(paiement: nil).update_all(paiement: false)

    change_column :allocation_prenatales, :paiement, :boolean, default: false, null: false
    change_column :allocation_postnatales, :paiement, :boolean, default: false, null: false
    change_column :allocation_familiales, :paiement, :boolean, default: false, null: false
  end

  def self.down
    remove_column :allocation_prenatales, :paiement_id
    remove_column :allocation_postnatales, :paiement_id
    remove_column :allocation_familiales, :paiement_id
  end
end
