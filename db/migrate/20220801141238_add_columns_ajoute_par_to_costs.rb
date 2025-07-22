class AddColumnsAjouteParToCosts < ActiveRecord::Migration[5.2]
  def change
    add_column :dossier_juridique_honoraires, :ajoute_par_id, :integer
  end
end
