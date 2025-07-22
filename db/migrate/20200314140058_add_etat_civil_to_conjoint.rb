class AddEtatCivilToConjoint < ActiveRecord::Migration[5.2]
  def change
    add_column :conjoints, :type_piece, :integer
    add_column :conjoints, :numero_piece, :string
  end
end
