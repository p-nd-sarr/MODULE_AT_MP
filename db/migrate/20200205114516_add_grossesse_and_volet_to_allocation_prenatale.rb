class AddGrossesseAndVoletToAllocationPrenatale < ActiveRecord::Migration[5.2]
  def change
    add_column :allocation_prenatales, :grossesse_valid, :boolean
    add_column :allocation_prenatales, :debut_grossesse, :date

    add_column :allocation_prenatales, :validation_volet1, :boolean
    add_column :allocation_prenatales, :validation_volet2, :boolean
    add_column :allocation_prenatales, :validation_volet3, :boolean
    add_column :allocation_prenatales, :validation_volet4, :boolean
    add_column :allocation_prenatales, :validation_volet5, :boolean
    add_column :allocation_prenatales, :validation_volet6, :boolean
    add_column :allocation_prenatales, :validation_volet7, :boolean
    add_column :allocation_prenatales, :validation_volet8, :boolean

    add_column :allocation_prenatales, :paiement_volet1, :boolean
    add_column :allocation_prenatales, :paiement_volet2, :boolean
    add_column :allocation_prenatales, :paiement_volet3, :boolean
    add_column :allocation_prenatales, :paiement_volet4, :boolean
    add_column :allocation_prenatales, :paiement_volet5, :boolean
    add_column :allocation_prenatales, :paiement_volet6, :boolean
    add_column :allocation_prenatales, :paiement_volet7, :boolean
    add_column :allocation_prenatales, :paiement_volet8, :boolean

    add_column :allocation_prenatales, :montant_volet1, :integer
    add_column :allocation_prenatales, :montant_volet2, :integer
    add_column :allocation_prenatales, :montant_volet3, :integer
    add_column :allocation_prenatales, :montant_volet4, :integer
    add_column :allocation_prenatales, :montant_volet5, :integer
    add_column :allocation_prenatales, :montant_volet6, :integer
    add_column :allocation_prenatales, :montant_volet7, :integer
    add_column :allocation_prenatales, :montant_volet8, :integer

    add_column :allocation_prenatales, :gestionnaire_compte_id, :bigint



  end
end
