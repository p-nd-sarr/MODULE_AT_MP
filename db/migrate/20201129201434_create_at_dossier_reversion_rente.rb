class CreateAtDossierReversionRente < ActiveRecord::Migration[5.2]
  def change
    create_table :at_dossier_reversion_rentes do |t|
      t.references :at_base_reversion_rente, foreign_key: true, null: true
      t.string :numero_affiliation, null: false
      t.string :prenom, null: false
      t.string :nom, null: false
      t.date :date_naissance
      t.date :date_mariage
      t.integer :type_ayant_droit
      t.string :numero_dossier, null: true
      t.string :workflow_state
      t.integer :conjoint_id, null: true
      t.integer :enfant_id, null: true
      t.integer :ascendants_salarie_id, null: true
    #  t.references :ascendants_salarie_mere, foreign_key: true, null: true
      t.string :nom_tuteur
      t.string :prenom_tuteur
      t.datetime :date_soumis
      t.integer :soumis_par_id
      t.integer :valider_par_id
      t.date :valider_le
      t.boolean :info_ayant_droit, default: false
      t.boolean :documents_valide,:boolean, default: false
      t.integer :ajoute_par
      t.date :ajouter_le
      t.string :etat
      t.string :workflow_state, :string
      t.timestamps
    end
  end
end
