class AddAProgramDeTravailToDossierAudit < ActiveRecord::Migration[5.2]
  def change
    add_column :dossier_audits, :programme_travail, :text
  end
end
