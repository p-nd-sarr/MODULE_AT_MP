class AddColumnsAjouteParToActs < ActiveRecord::Migration[5.2]
  def change
    add_column :dossier_juridique_actes, :ajoute_par_id, :integer
  end
end
