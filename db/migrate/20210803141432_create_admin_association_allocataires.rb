class CreateAdminAssociationAllocataires < ActiveRecord::Migration[5.2]
  def change
    create_table :admin_association_allocataires do |t|
      t.string :name

      t.timestamps
    end
  end
end
