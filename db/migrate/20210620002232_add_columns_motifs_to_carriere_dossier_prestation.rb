class AddColumnsMotifsToCarriereDossierPrestation < ActiveRecord::Migration[5.2]
  def change
    add_column :carriere_dossier_prestations, :motif_mois1, :string
    add_column :carriere_dossier_prestations, :motif_mois2, :string
    add_column :carriere_dossier_prestations, :motif_mois3, :string
  end
end
