class UpdateTypeNombreEnfantsFromEcheanceCaisseDossier < ActiveRecord::Migration[5.2]
  def change
    change_column :echeance_caisse_dossiers, :nombre_enfants, :integer, using: 'nombre_enfants::integer'
    change_column :echeance_caisse_dossiers, :nombre_total_enfants_eligibles, :integer, using: 'nombre_total_enfants_eligibles::integer'
  end
end
