class AddColumnRangToConjoint < ActiveRecord::Migration[5.2]
  def change
    add_column :conjoints, :rang_conjoint, :integer
  end
end
