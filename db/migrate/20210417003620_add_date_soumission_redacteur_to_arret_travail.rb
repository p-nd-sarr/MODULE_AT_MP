class AddDateSoumissionRedacteurToArretTravail < ActiveRecord::Migration[5.2]
  def change
    add_column :arret_travails, :date_soumission_redacteur, :datetime
    add_column :arret_travails, :date_soumission_dajc, :datetime
  end
end
