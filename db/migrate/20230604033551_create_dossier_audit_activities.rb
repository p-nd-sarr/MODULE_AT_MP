class CreateDossierAuditActivities < ActiveRecord::Migration[5.2]
  def change
    create_table :dossier_audit_activities do |t|
      t.integer :ajoute_par_id
      t.string :description
      t.references :dossier_audits, foreign_key: true

      t.timestamps
    end
  end
end
