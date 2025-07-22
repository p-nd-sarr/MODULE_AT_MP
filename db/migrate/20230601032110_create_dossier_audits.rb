class CreateDossierAudits < ActiveRecord::Migration[5.2]
  def change
    create_table :dossier_audits do |t|
      t.string :num_dossier
      t.string :description
      t.string :motif
      t.string :objectifs
      t.string :etendu_controle
      t.string :techniques_controle
      t.date :date_debut

      t.integer :ajoute_par_id
      t.integer :soumis_par_id
      t.integer :cloture_par_id

      t.date :date_soumission
      t.date :date_cloture

      t.string :workflow_state
      t.string :status

      t.timestamps
    end
  end
end
