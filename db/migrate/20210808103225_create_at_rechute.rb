class CreateAtRechute < ActiveRecord::Migration[5.2]
  def change
    create_table :at_rechutes do |t|
      t.references :arret_travail
      t.string :workflow_state
      t.text :motif
      t.boolean :information_generale,:boolean, default: false
      t.boolean :documents_valide,:boolean, default: false
      t.boolean :information_salaire, default: false
      t.integer :soumis_par
      t.date :date_soumission
      t.integer :ajoute_par_id
      t.date :ajouter_le
      t.integer :valide_par_id
      t.date :date_validation
      t.date :date_rechute
      t.timestamps
    end
  end
end
