class AddCommentaireMissingDeclaration < ActiveRecord::Migration[5.2]
  def change

    add_column :missing_declarations, :commentaire ,:text
    add_column :missing_declarations, :soumis_par_id, :integer
    add_column :missing_declarations, :soumis_le, :datetime
  end
end
