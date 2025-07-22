class AddColumnsDebutChangementModeToAllocataire < ActiveRecord::Migration[5.2]
  def change
    add_column :allocataires, :date_debut_changement, :date
    add_column :allocataires, :motif_virement, :integer
  end
end
