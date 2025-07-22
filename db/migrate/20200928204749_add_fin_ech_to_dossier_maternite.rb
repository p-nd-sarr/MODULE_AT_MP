class AddFinEchToDossierMaternite < ActiveRecord::Migration[5.2]
  def change
    add_column :dossier_maternites, :date_echeance, :date
  end
end
