class AddColumnSexeToCafConjoint < ActiveRecord::Migration[5.2]
  def change
    add_column :caf_conjoints, :sexe, :string
  end
end
