class AddColumnsNameToAllocationsFamilialesMigrees < ActiveRecord::Migration[5.2]
  def change
    add_column :allocations_familiales_migrees, :enfant_nom, :string
    add_column :allocations_familiales_migrees, :enfant_prenom, :string
  end
end
