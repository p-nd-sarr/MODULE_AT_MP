class AddSoumisDirecteurParToDossierAudit < ActiveRecord::Migration[5.2]
  def change
    add_column :dossier_audits, :soumis_directeur_par_id, :integer
  end
end
