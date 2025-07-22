class AddOldDossierMaterniteIdToDossierMaternite < ActiveRecord::Migration[5.2]
  def change
    add_column :dossier_maternites, :old_dossier_maternite_id, :integer
  end
end
