class AddReprisToAllocataire < ActiveRecord::Migration[5.2]
  def change
    add_column :allocataires, :est_repris, :boolean, default: false
  end
end
