class AddPointCarriere < ActiveRecord::Migration[5.2]
  def change
    add_column :carrieres, :points, :integer, default: 0
    add_column :carrieres, :salaire1, :float, default: 0
    add_column :carrieres, :salaire2, :float, default: 0
    add_column :carrieres, :exercice, :string

  end
end
