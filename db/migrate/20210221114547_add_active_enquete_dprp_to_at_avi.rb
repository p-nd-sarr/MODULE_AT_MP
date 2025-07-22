class AddActiveEnqueteDprpToAtAvi < ActiveRecord::Migration[5.2]
  def change
    add_column :arret_travails, :active_enquete_dprp, :boolean, default: false
    add_column :arret_travails, :active_avis_medecin, :boolean, default: false
    add_column :arret_travails, :desc_dprp, :string
    add_column :arret_travails, :desc_medecin, :string
  end
end
