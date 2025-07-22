class CreateEcheanceCaisseDossiers < ActiveRecord::Migration[5.2]
  def change
    create_table :echeance_caisse_dossiers do |t|
      t.references :echeance_caisse, foreign_key: true
      t.references :dossier_prestation, foreign_key: true
      t.string :workflow_state, limit: 50
      t.string :employeur_actuel, index: true
      t.string :num_affiliation, index: true
      t.string :nin
      t.string :prenom
      t.string :nom
      t.string :nombre_enfants
      t.string :nombre_total_enfants_eligibles

      t.timestamps
    end
  end
end
