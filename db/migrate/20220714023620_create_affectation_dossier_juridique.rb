class CreateAffectationDossierJuridique < ActiveRecord::Migration[5.2]
  def change
    create_table :affectation_dossier_juridiques do |t|
      t.integer :affecte_par_id
      t.integer :affecte_a_id
      t.date :date_affectation
      t.references :dossier_juridiques, foreign_key: true

      t.timestamps
    end
  end
end
