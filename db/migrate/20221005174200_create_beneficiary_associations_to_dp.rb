class CreateBeneficiaryAssociationsToDp < ActiveRecord::Migration[5.2]
  def change
    create_table :beneficiary_associations_to_dps do |t|

      t.references :dossier_prestation
      t.references :conjoint
      t.references :enfant

      t.timestamps

    end
  end
end
