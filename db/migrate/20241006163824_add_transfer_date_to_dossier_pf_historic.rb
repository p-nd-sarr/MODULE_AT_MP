class AddTransferDateToDossierPfHistoric < ActiveRecord::Migration[5.2]
  def change
    add_column :dossier_prestation_historics, :transfer_date, :date

  end
end
