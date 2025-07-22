class AddColumnToDeclaration < ActiveRecord::Migration[5.2]
  def change
    add_column :declarations, :effectif, :integer, default: 0
  end
end