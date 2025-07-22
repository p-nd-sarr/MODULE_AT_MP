class CreateAdminBanqueAgences < ActiveRecord::Migration[5.2]
  def change
    create_table :admin_banque_agences do |t|
      t.references :admin_banque, foreign_key: true
      t.string :nom, null: false
      t.string :code, null: false
      t.string :bank_branch_id, null: false

      t.timestamps
    end
  end
end
