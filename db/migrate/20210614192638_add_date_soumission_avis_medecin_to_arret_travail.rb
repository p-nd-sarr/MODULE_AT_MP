class AddDateSoumissionAvisMedecinToArretTravail < ActiveRecord::Migration[5.2]
  def change
    add_column :arret_travails, :date_soumission_avis_medecin, :datetime
    add_column :arret_travails, :date_soumission_avis_dprp, :datetime
  end
end
