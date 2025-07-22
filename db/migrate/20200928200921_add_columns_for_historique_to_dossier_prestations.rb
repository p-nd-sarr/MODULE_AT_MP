class AddColumnsForHistoriqueToDossierPrestations < ActiveRecord::Migration[5.2]
  def change
    add_column :dossier_prestations, :suspendu_par_id, :integer
    add_column :dossier_prestations, :date_suspension, :date
  end
end
