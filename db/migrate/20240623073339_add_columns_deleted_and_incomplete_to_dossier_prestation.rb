class AddColumnsDeletedAndIncompleteToDossierPrestation < ActiveRecord::Migration[5.2]
  def change
    add_column :dossier_prestations, :deleted, :boolean, default: false
    add_column :dossier_prestations, :incomplete, :boolean, default: false
  end
end
