class AddColumnsBackToIndemnitesPrestation < ActiveRecord::Migration[5.2]
  def change
    add_column :indemnites_prestation_exterieures, :motif_retour, :string
    add_column :indemnites_prestation_exterieures, :date_retour, :date
    add_column :indemnites_prestation_exterieures, :retourne_par_id, :integer
  end
end
