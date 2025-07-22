class AddDossierDemandeurValideToReversionVeuveSalarie < ActiveRecord::Migration[5.2]
  def change
    add_column :reversion_veuve_salaries, :dossier_demandeur_valide, :boolean, default: false
  end
end
