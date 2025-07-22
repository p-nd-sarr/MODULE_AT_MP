class AddMotifSuspensionToAllocataire < ActiveRecord::Migration[5.2]
  def change
    add_column :allocataires, :motif_suspension, :text
  end
end
