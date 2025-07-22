class AddColumnToConjoint < ActiveRecord::Migration[5.2]
  def change
    add_column :conjoints, :nom_conjoint, :string
    add_column :conjoints, :prenom_conjoint, :string
  end
end
