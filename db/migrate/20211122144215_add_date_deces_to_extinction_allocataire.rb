class AddDateDecesToExtinctionAllocataire < ActiveRecord::Migration[5.2]
  def change
    add_column :extinction_allocataires, :date_deces, :datetime
  end
end
