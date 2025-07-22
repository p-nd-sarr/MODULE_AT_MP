class AddMaintienPrestationToAllocationF < ActiveRecord::Migration[5.2]
  def change
    add_column :allocation_familiales, :maintien_prestation_id, :integer
  end
end
