class AddFieldDeclaration < ActiveRecord::Migration[5.2]
  def change
    add_column :declarations, :mouvement_effectif_valide, :boolean
    add_column :declarations, :recap_salarie_valide, :boolean
    add_column :declarations, :synthese_valide, :boolean
    add_column :declarations, :etat, :boolean
    add_column :declarations, :date_soumission, :date

  end
end