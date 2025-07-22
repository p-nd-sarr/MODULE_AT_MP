class AddColumnSoumisParToAllocationFamiliale < ActiveRecord::Migration[5.2]
  def change
    add_column :allocation_familiales, :soumis_par_id, :integer
  end
end
