class AddZonesToAllocataire < ActiveRecord::Migration[5.2]
  def change
    add_column :allocataires, :zone, :integer, null: true
    add_reference :allocataires, :admin_region, foreign_key: true, null: true
  end
end
