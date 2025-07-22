class RemoveVolet4To8FromAllocationPrenatale < ActiveRecord::Migration[5.2]
  def change
    remove_column :allocation_prenatales, :validation_volet4
    remove_column :allocation_prenatales, :validation_volet5
    remove_column :allocation_prenatales, :validation_volet6
    remove_column :allocation_prenatales, :validation_volet7
    remove_column :allocation_prenatales, :validation_volet8

    remove_column :allocation_prenatales, :paiement_volet4
    remove_column :allocation_prenatales, :paiement_volet5
    remove_column :allocation_prenatales, :paiement_volet6
    remove_column :allocation_prenatales, :paiement_volet7
    remove_column :allocation_prenatales, :paiement_volet8

    remove_column :allocation_prenatales, :montant_volet4
    remove_column :allocation_prenatales, :montant_volet5
    remove_column :allocation_prenatales, :montant_volet6
    remove_column :allocation_prenatales, :montant_volet7
    remove_column :allocation_prenatales, :montant_volet8
  end
end
