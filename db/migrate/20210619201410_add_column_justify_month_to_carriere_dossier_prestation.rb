class AddColumnJustifyMonthToCarriereDossierPrestation < ActiveRecord::Migration[5.2]
  def change
    add_column :carriere_dossier_prestations, :est_justifier_mois2, :boolean
    add_column :carriere_dossier_prestations, :est_justifier_mois3, :boolean
  end
end
