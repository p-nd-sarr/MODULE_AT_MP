class AddMultipleColumnToMaladieProfessionnelles < ActiveRecord::Migration[5.2]
  def change
    add_column :maladie_professionnelles, :numero_ipress_css_salarie, :string
    add_column :maladie_professionnelles, :dossier_initial_salarie, :string
    add_column :maladie_professionnelles, :date_rechute_salarie, :date
    add_column :maladie_professionnelles, :salaire_du_jour, :float
    add_column :maladie_professionnelles, :salaire_du_mois, :float
    add_column :maladie_professionnelles, :numero_unique_ipress_css_employeur, :string
    add_column :maladie_professionnelles, :ancien_numero_ipress_employeur, :string
    add_column :maladie_professionnelles, :ancien_numero_css_employeur, :string
    add_column :maladie_professionnelles, :status_ipress, :integer
    add_column :maladie_professionnelles, :status_css, :integer
    add_column :maladie_professionnelles, :status_ipress_css, :integer
    add_column :maladie_professionnelles, :solde_total_ipress_css, :float
    add_column :maladie_professionnelles, :solde_branche_vieillesse, :float
    add_column :maladie_professionnelles, :solde_branche_at, :float
    add_column :maladie_professionnelles, :solde_branche_pf, :float
    add_column :maladie_professionnelles, :agence_gestion_ipress, :string
    add_column :maladie_professionnelles, :agence_gestion_css, :string
    add_column :maladie_professionnelles, :taux_at, :float
    add_column :maladie_professionnelles, :taux_pf, :float
  end
end
