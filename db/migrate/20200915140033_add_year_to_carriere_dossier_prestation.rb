class AddYearToCarriereDossierPrestation < ActiveRecord::Migration[5.2]
  def change
    add_column :carriere_dossier_prestations, :annee, :integer
  end
end
