class AddFieldMotifCarreire < ActiveRecord::Migration[5.2]
  def change
    add_column :carrieres, :motif, :string
  end
end
