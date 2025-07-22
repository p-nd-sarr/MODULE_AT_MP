class AddFieldMissingDeclaration < ActiveRecord::Migration[5.2]
  def change
    add_column :missing_declarations, :etat, :integer, default: 3

  end
end