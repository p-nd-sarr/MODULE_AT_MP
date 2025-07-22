class AddDateCongesToDossierMaternite < ActiveRecord::Migration[5.2]
  def change
    add_column :dossier_maternites, :debut_conges, :date
  end
end
