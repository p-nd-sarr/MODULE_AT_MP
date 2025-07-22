class AddSiteToDossierMaternite < ActiveRecord::Migration[5.2]
  def change
    add_column :dossier_maternites, :site, :integer
  end
end
