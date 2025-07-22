class AlterTableDossierMaternite < ActiveRecord::Migration[5.2]
  def change
    remove_column :dossier_maternites, :categorie_travail
    remove_column :dossier_maternites, :date_embauche

    add_column :dossier_maternites, :categorie_travail, :integer
    add_column :dossier_maternites, :date_embauche, :date
  end
end
