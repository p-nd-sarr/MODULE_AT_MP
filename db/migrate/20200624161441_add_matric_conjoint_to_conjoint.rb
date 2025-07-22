class AddMatricConjointToConjoint < ActiveRecord::Migration[5.2]
  def change
    add_column :conjoints, :matric_conjoint, :string
  end
end
