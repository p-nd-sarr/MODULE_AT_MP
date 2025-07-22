class AddColumnRejeteParToAllocationF < ActiveRecord::Migration[5.2]
  def change
    add_column :allocation_familiales, :rejete_par_id, :integer, null: true
  end
end
