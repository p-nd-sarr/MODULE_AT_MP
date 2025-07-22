class UpdateTypeSalaireDeclaration < ActiveRecord::Migration[5.2]
  def change


    remove_column :missing_ligne_declarations, :salaire_soumis
    remove_column :missing_ligne_declarations, :salaire_reel

    add_column :missing_ligne_declarations, :salaire_soumis, :decimal
    add_column :missing_ligne_declarations, :salaire_reel, :decimal
  end
end
