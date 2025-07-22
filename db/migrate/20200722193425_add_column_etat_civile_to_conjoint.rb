class AddColumnEtatCivileToConjoint < ActiveRecord::Migration[5.2]
  def change
    add_column :conjoints, :etat_civil, :integer
  end
end
