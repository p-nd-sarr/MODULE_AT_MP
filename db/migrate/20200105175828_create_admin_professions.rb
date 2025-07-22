class CreateAdminProfessions < ActiveRecord::Migration[5.2]
  def change
    create_table :admin_professions do |t|
      t.string :code, null: false
      t.string :description, null: false

      t.timestamps
    end
  end
end
