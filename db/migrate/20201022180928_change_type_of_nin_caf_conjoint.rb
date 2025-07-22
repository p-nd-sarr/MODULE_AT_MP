class ChangeTypeOfNinCafConjoint < ActiveRecord::Migration[5.2]
  def change
    change_column :caf_conjoints, :nin_conjoint, :string
  end
end
