class AddInfosLiquidationToAllocataire < ActiveRecord::Migration[5.2]
  def change
    add_column :allocataires, :regime, :integer
    add_column :allocataires, :age_revolu, :integer, default: 0

    add_column :allocataires, :moyenne_rg, :float, default: 0
    add_column :allocataires, :mois_gratuis_rg, :float, default: 0
    add_column :allocataires, :points_rg, :float, default: 0
    add_column :allocataires, :points_base_rg, :float, default: 0
    add_column :allocataires, :pourcentage_minoration_rg, :float, default: 0
    add_column :allocataires, :point_minoration_rg, :float, default: 0
    add_column :allocataires, :pourcentage_majoration_rg, :float, default: 0
    add_column :allocataires, :point_majoration_rg, :float, default: 0
    add_column :allocataires, :points_complementaires_rg, :float, default: 0
    add_column :allocataires, :points_servis_rg, :float, default: 0
    add_column :allocataires, :montant_brut_rg, :float, default: 0
    add_column :allocataires, :montant_imposable_rg, :float, default: 0
    add_column :allocataires, :moyenne_rc, :float, default: 0
    add_column :allocataires, :mois_gratuis_rc, :float, default: 0
    add_column :allocataires, :points_rc, :float, default: 0
    add_column :allocataires, :points_base_rc, :float, default: 0
    add_column :allocataires, :pourcentage_minoration_rc, :float, default: 0
    add_column :allocataires, :point_minoration_rc, :float, default: 0
    add_column :allocataires, :pourcentage_majoration_rc, :float, default: 0
    add_column :allocataires, :point_majoration_rc, :float, default: 0
    add_column :allocataires, :points_complementaires_rc, :float, default: 0
    add_column :allocataires, :points_servis_rc, :float, default: 0
    add_column :allocataires, :montant_brut_rc, :float, default: 0
    add_column :allocataires, :montant_imposable_rc, :float, default: 0
    add_column :allocataires, :montant_net, :float, default: 0
    add_column :allocataires, :montant_minimum_fiscal, :float, default: 0
    add_column :allocataires, :montant_igr, :float, default: 0
    add_column :allocataires, :montant_rappel, :float, default: 0
    add_column :allocataires, :montant_premier_paiement, :float, default: 0

    add_column :allocataires, :versement_unique, :boolean
    add_column :allocataires, :date_jouissance, :date
  end
end
