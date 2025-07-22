class CreateAtBaseReversionRente < ActiveRecord::Migration[5.2]
  def change
    create_table :at_base_reversion_rentes do |t|
      t.references :arret_travail, foreign_key: true
      t.string :numero_affiliation, null: false
      t.date :date_deces
      t.string :workflow_state, :string
      t.string :num_dossier
      t.integer :soumis_par
      t.date :date_soumission
      t.integer :ajoute_par
      t.date :ajouter_le
      t.string :conjoints_id, array: true, default: []
      t.string :enfants_id, array: true, default: []
      t.string :ascendants_pere_id, array: true, default: []
      t.string :ascendants_mere_id, array: true, default: []
      t.boolean :info_reversion, default: false
      t.boolean :documents_valide,:boolean, default: false
      t.timestamps
    end
  end
end
