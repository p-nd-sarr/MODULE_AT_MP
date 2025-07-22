class AddAgenceToDossierAudit < ActiveRecord::Migration[5.2]
  def change
    add_reference :dossier_audits, :admin_agence, foreign_key: true
  end
end
