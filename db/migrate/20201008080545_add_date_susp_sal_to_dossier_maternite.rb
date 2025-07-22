class AddDateSuspSalToDossierMaternite < ActiveRecord::Migration[5.2]
  def change
    add_column :dossier_maternites, :date_suspension_salaire, :date
  end
end
