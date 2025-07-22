class CreateAtRenteFamilles < ActiveRecord::Migration[5.2]
  def change
    create_table :at_rente_familles do |t|
      t.references :arret_travail
      t.string :workflow_state, :string
      t.string :soumis_par, :integer
      t.string :date_soumission, :datetime
      t.text :motif
      t.boolean :information_defunt, default: false
      t.boolean :documents_valide,:boolean, default: false
      t.boolean :information_salaire, default: false
      t.boolean :epouses_valide, default: false
      t.boolean :enfants_valide, default: false
      t.boolean :ascendants_valide, default: false
      t.boolean :tableau_rente_valide, default: false
      t.integer :soumis_par
      t.date :date_deces
      t.date :date_soumission
      t.integer :ajoute_par_id
      t.timestamps
    end
  end
end
