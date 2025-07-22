class AddColumnsDeletedAndIncompleteToConjoint < ActiveRecord::Migration[5.2]
  def change
    add_column :conjoints, :deleted, :boolean, default: false
    add_column :conjoints, :incomplete, :boolean, default: false
  end
end
