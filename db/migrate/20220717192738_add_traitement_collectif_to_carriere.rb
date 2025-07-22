class AddTraitementCollectifToCarriere < ActiveRecord::Migration[5.2]
  def change
    add_column :carriere_dossier_prestations, :bordereau_collectif_id, :integer
  end
end
