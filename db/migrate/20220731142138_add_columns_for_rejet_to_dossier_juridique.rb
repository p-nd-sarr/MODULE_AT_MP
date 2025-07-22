class AddColumnsForRejetToDossierJuridique < ActiveRecord::Migration[5.2]
  def change
    add_column :dossier_juridiques, :rejete_par_id, :integer
    add_column :dossier_juridiques, :date_rejet, :date
  end
end
