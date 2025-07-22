class AddColumnEtatCoupleToCafConjoint < ActiveRecord::Migration[5.2]
  def change
    add_column :caf_conjoints, :etat_couple, :integer
  end
end
