class AddTraitementCollectifToAllocationF < ActiveRecord::Migration[5.2]
  def change
    add_column :allocation_familiales, :bordereau_collectif_id, :integer
  end
end
