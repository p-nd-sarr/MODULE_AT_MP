class ChangeTypeOfCafConjoint < ActiveRecord::Migration[5.2]
  def change
    change_column :caf_conjoints, :sexe, 'integer USING CAST(sexe AS integer)'
  end
end
