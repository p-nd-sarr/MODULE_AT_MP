class AddColumnsToConjoint < ActiveRecord::Migration[5.2]
  def change
    add_column :conjoints, :date_delivrance_piece, :date
    add_column :conjoints, :date_expiration_piece, :date
  end
end
