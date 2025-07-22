class AddSoumisParInArretTravail < ActiveRecord::Migration[5.2]
  def change
    add_column :arret_travails, :cloture_soumise_par, :integer
    add_column :arret_travails, :reouverture_soumise_par, :integer
  end
end
