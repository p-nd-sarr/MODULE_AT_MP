class AddColumnSexToConjoint < ActiveRecord::Migration[5.2]
  def change
    add_column :conjoints, :sex, :integer
  end
end
