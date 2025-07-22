class CreateAdminRegBeneficiaries < ActiveRecord::Migration[5.2]
  def change
    create_table :reg_beneficiaries do |t|

      t.string :prenom
      t.string :nom
      t.date :date_naissance
      t.string :nin
      t.string :telephone

      t.references :regularisation_pensions

      t.timestamps
    end
  end
end
