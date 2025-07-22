class AddColumnsToCarriereDossierPrestation < ActiveRecord::Migration[5.2]
  def change
    add_column :carriere_dossier_prestations, :num_employeur_mois_2, :string
    add_column :carriere_dossier_prestations, :raison_sociale_employeur_mois_2, :string
    add_column :carriere_dossier_prestations, :num_employeur_mois_3, :string
    add_column :carriere_dossier_prestations, :raison_sociale_employeur_mois_3, :string
  end
end
