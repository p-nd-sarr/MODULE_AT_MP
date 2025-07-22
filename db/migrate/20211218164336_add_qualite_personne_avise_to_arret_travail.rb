class AddQualitePersonneAviseToArretTravail < ActiveRecord::Migration[5.2]
  def change
    add_column :arret_travails, :personne_avisee_qualite, :string
  end
end
