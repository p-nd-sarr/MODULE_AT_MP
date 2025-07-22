class CreateAtGuerisons < ActiveRecord::Migration[5.2]
  def change
    create_table :at_guerisons do |t|
      t.references :arret_travail
      t.text :observation
      t.integer :soumis_par_id
      t.string :workflow_state
      t.text :motif
      t.boolean :information_generale,:boolean, default: false
      t.boolean :documents_valide,:boolean, default: false
      t.integer :soumis_par_id
      t.date :date_soumission
      t.integer :ajoute_par_id
      t.date :ajouter_le
      t.integer :valide_par_id
      t.date :date_validation
      t.date :date_ouverture_guerison
      
      t.timestamps
    end
  end
end
