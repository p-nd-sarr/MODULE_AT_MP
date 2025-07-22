class AddColummnTypePieceToCafEnfant < ActiveRecord::Migration[5.2]
  def change
    add_column :caf_enfants, :type_piece, :integer
  end
end
