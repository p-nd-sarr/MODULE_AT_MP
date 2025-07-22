class AddcolumnEtatAndRegimeToConjoint < ActiveRecord::Migration[5.2]
  def change
    add_column :conjoints, :etat_conjoint, :integer
    add_column :conjoints, :regime_matrimoniale, :integer
  end
end
