class AddColumnsPieceAndTypeToCafConjoint < ActiveRecord::Migration[5.2]
  def change
    add_column :caf_conjoints, :type_piece, :integer
    add_column :caf_conjoints, :nin_conjoint, :integer
  end
end
