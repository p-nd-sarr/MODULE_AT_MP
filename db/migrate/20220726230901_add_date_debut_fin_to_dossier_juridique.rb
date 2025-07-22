class AddDateDebutFinToDossierJuridique < ActiveRecord::Migration[5.2]
  def change
    add_column :dossier_juridiques, :date_debut_contrat, :date
    add_column :dossier_juridiques, :date_fin_contrat, :date
  end
end
