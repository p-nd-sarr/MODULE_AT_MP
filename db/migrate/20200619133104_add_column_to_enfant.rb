class AddColumnToEnfant < ActiveRecord::Migration[5.2]
  def change
    add_column :enfants, :type_piece, :integer
    add_column :enfants, :numero_piece, :string
  end
end