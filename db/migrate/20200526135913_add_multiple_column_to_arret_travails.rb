class AddMultipleColumnToArretTravails < ActiveRecord::Migration[5.2]
  def change
    add_column :arret_travails, :numero_ipress_css_salarie, :string
    add_column :arret_travails, :dossier_initial_salarie, :string
    add_column :arret_travails, :date_rechute_salarie, :date
    add_column :arret_travails, :salaire_du_jour, :float
    add_column :arret_travails, :salaire_du_mois, :float
    add_column :arret_travails, :numero_unique_ipress_css_employeur, :string
    add_column :arret_travails, :ancien_numero_ipress_employeur, :string
    add_column :arret_travails, :ancien_numero_css_employeur, :string
    add_column :arret_travails, :status_ipress, :integer
    add_column :arret_travails, :status_css, :integer
    add_column :arret_travails, :status_ipress_css, :integer
    add_column :arret_travails, :solde_total_ipress_css, :float
    add_column :arret_travails, :solde_branche_vieillesse, :float
    add_column :arret_travails, :solde_branche_at, :float
    add_column :arret_travails, :solde_branche_pf, :float
    add_column :arret_travails, :agence_gestion_ipress, :string
    add_column :arret_travails, :agence_gestion_css, :string
    add_column :arret_travails, :taux_at, :float
    add_column :arret_travails, :taux_pf, :float
  end
end
