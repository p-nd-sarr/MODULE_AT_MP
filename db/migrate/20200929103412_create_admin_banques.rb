class CreateAdminBanques < ActiveRecord::Migration[5.2]
  def change
    create_table :admin_banques do |t|
      t.string :code
      t.string :description
      t.boolean :actif

      t.timestamps
    end
  end
end
