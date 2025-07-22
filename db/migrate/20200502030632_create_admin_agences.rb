class CreateAdminAgences < ActiveRecord::Migration[5.2]
  def change
    create_table :admin_agences do |t|
      t.integer :type_agence
      t.string :code
      t.string :description_ebs
      t.string :code_prest
      t.string :description_prest
      t.string :code_psrm
      t.string :description_psrm
      t.string :code_site

      t.timestamps
    end
  end
end
