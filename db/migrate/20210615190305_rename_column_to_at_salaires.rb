class RenameColumnToAtSalaires < ActiveRecord::Migration[5.2]
  def change
    add_column :at_salaires, :at_consolidation_id, :integer
    remove_column :at_salaires, :arret_travail_id, :integer
  end
end
