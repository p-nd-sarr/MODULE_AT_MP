class AddDateDecesToAllocataire < ActiveRecord::Migration[5.2]
  def change
    add_column :allocataires, :date_deces, :datetime
  end
end
