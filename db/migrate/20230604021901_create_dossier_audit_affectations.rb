class CreateDossierAuditAffectations < ActiveRecord::Migration[5.2]
  def change
    create_table :dossier_audit_affectations do |t|
      t.integer :affecte_par_id
      t.integer :affecte_a_id
      t.date :date_affectation
      t.references :dossier_audits, foreign_key: true

      t.timestamps
    end
  end
end
