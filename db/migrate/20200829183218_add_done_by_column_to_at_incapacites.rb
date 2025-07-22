class AddDoneByColumnToAtIncapacites < ActiveRecord::Migration[5.2]
  def change
    add_column :at_incapacites, :done_by, :integer
  end
end
