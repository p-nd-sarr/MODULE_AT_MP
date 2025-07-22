class DeleteColumnConjointToAscendantsSalarie < ActiveRecord::Migration[5.2]
  def change
    remove_column :ascendants_salaries, :conjoint_id, :integer
  end
end
