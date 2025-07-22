class AddClotureParToDossierPrestation < ActiveRecord::Migration[5.2]
  def change
    add_column :dossier_prestations, :cloture_par_id, :integer
  end
end
