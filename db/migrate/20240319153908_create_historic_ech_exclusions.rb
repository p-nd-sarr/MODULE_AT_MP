class CreateHistoricEchExclusions < ActiveRecord::Migration[5.2]
  def change
    create_table :historic_ech_exclusions do |t|
      t.references :echeance_caisse
      t.references :echeance_caisse_employeur
      t.references :dossier_presttaion
      t.integer :ajoute_par_id

      t.timestamps
    end
  end
end
