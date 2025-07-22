class AddAdminAgenceToDossierMaternite < ActiveRecord::Migration[5.2]
  def change
    add_column :dossier_maternites, :admin_agence_id, :integer
  end
end
