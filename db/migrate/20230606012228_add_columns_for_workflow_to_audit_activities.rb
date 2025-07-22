class AddColumnsForWorkflowToAuditActivities < ActiveRecord::Migration[5.2]
  def change
    add_column :dossier_audit_activities, :motif_rejet, :text
    add_column :dossier_audit_activities, :soumis_par_id, :integer
    add_column :dossier_audit_activities, :valide_par_id, :integer
    add_column :dossier_audit_activities, :date_soumission, :date
    add_column :dossier_audit_activities, :date_validation, :date
  end
end
