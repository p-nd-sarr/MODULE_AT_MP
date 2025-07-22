class AddTypePieceToDossMat < ActiveRecord::Migration[5.2]
  def change
    add_column :dossier_maternites, :type_piece, :integer
  end
end
