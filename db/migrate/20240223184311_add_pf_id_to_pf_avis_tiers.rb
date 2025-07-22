class AddPfIdToPfAvisTiers < ActiveRecord::Migration[5.2]
  def change
    add_reference :dossier_prestation_avis_tiers, :dossier_prestation
  end
end
