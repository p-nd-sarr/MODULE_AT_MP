class AddEstReprisToCssTables < ActiveRecord::Migration[5.2]
  def change
    add_column :conjoints, :est_repris, :boolean, null: false, default: false
    add_column :enfants, :est_repris, :boolean, null: false, default: false
    add_column :dossier_prestations, :est_repris, :boolean, null: false, default: false
    add_column :dossier_maternites, :est_repris, :boolean, null: false, default: false
    add_column :allocataire_pfs, :est_repris, :boolean, null: false, default: false
    add_column :allocation_familiales, :est_repris, :boolean, null: false, default: false
    add_column :allocation_postnatales, :est_repris, :boolean, null: false, default: false
    add_column :allocation_prenatales, :est_repris, :boolean, null: false, default: false
    add_column :indemnite_conges_maternites, :est_repris, :boolean, null: false, default: false
    add_column :carriere_dossier_maternites, :est_repris, :boolean, null: false, default: false
    add_column :carriere_dossier_prestations, :est_repris, :boolean, null: false, default: false
  end
end
