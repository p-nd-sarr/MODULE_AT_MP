class CreateEcheanceVeuvesCaisseEpouses < ActiveRecord::Migration[5.2]
  def change
    create_table :echeance_veuves_caisse_epouses do |t|
      t.references :echeance_veuves_caisse, foreign_key: true, index: { name: :echeance_veuves_caisse_id }
      t.string :workflow_state, limit: 50
      t.string :numero_affiliation, index: true
      t.string :conjoint_id, index: true
      t.string :agence_id, index: true
      t.string :prenom
      t.string :nom
      t.string :nin
      t.integer :nombre_enfants
      t.integer :nombre_total_enfants_eligibles
      t.date :date_naissance
      t.boolean :est_repris

      t.timestamps
    end
  end
end
