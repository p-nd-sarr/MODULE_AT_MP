class RenameDossierMaternitesIdToDossierMaterniteId < ActiveRecord::Migration[5.2]
  def change
    rename_column :dossier_maternite_avis_tiers, :dossier_maternites_id, :dossier_maternite_id
  end
end
