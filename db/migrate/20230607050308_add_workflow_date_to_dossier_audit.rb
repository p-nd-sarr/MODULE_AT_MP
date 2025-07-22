class AddWorkflowDateToDossierAudit < ActiveRecord::Migration[5.2]
  def change
    rename_column :dossier_audits, :date_cloture, :date_validation
    add_column :dossier_audits, :date_cloture, :date
    add_column :dossier_audits, :date_soumission_directeur, :date
  end
end
