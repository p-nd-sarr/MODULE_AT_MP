class AddValideParToDossierAudit < ActiveRecord::Migration[5.2]
  def change
    rename_column :dossier_audits, :cloture_par_id, :valide_par_id
    add_column :dossier_audits, :cloture_par_id, :integer
  end
end
