class UpdateMotifSortiDeclaration < ActiveRecord::Migration[5.2]
  def change
    remove_column :missing_ligne_declarations, :motif_sortie
    add_column :missing_ligne_declarations, :motif_sortie, :integer
  end
end
