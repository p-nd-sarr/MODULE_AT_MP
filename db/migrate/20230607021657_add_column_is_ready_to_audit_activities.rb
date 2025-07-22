class AddColumnIsReadyToAuditActivities < ActiveRecord::Migration[5.2]
  def change
    add_column :dossier_audit_activities, :is_ready, :boolean, :default => false
  end
end
