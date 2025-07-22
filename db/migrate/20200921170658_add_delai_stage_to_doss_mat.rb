class AddDelaiStageToDossMat < ActiveRecord::Migration[5.2]
  def change
    add_column :dossier_maternites, :delai_stage, :integer, default: 0, null: false

    remove_column :indemnite_conges_maternites, :nbre_jr_repos
    add_column :indemnite_conges_maternites, :nbre_jr_repos, :integer, default: 0, null: false
  end
end
