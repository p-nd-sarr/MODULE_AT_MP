class AddColumnsDeletedAndIncompleteToDossierMaternite < ActiveRecord::Migration[5.2]
  def change
    add_column :dossier_maternites, :deleted, :boolean, default: false
    add_column :dossier_maternites, :incomplete, :boolean, default: false
  end
end
