class AddColumnsToDossierActivities < ActiveRecord::Migration[5.2]
  def change
    add_column :dossier_audit_activities, :incident, :text
    add_column :dossier_audit_activities, :evaluation_incident, :text
    add_column :dossier_audit_activities, :plan_actions, :text
    add_column :dossier_audit_activities, :workflow_state, :string
  end
end
