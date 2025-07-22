class AddHasNumeroAffiliationToArretTravail < ActiveRecord::Migration[5.2]
  def change
    add_column :arret_travails, :has_numero_affiliation, :boolean, default: true
    add_column :arret_travails, :numero_temporaire, :string
  end
end
