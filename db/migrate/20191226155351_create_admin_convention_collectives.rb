class CreateAdminConventionCollectives < ActiveRecord::Migration[5.2]
  def change
    create_table :admin_convention_collectives do |t|
      t.string :code
      t.string :description

      t.timestamps
    end
  end
end
