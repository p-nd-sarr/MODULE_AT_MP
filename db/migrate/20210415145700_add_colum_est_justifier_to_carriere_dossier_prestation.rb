class AddColumEstJustifierToCarriereDossierPrestation < ActiveRecord::Migration[5.2]
  def change
    add_column :carriere_dossier_prestations, :est_justifier, :boolean
  end
end
