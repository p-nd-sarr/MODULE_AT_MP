class AddMotifAnnualtionGuerisonToArretTravail < ActiveRecord::Migration[5.2]
  def change
    add_column :arret_travails, :date_annulation_guerison, :datetime
    add_column :arret_travails, :motif_annulation_guerison, :string
  end
end
