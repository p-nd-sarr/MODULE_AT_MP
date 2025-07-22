class AddAutresPointsToMontantRevision < ActiveRecord::Migration[5.2]
  def change
    add_column :montant_revisions, :points_servis, :integer
    add_column :montant_revisions, :points_gratuits, :integer

    add_column :montant_revisions, :montant_revision_rc, :float
    add_column :montant_revisions, :points_cotisation_rc, :integer
    add_column :montant_revisions, :points_minoration_rc, :integer
    add_column :montant_revisions, :points_base_rc, :integer
    add_column :montant_revisions, :points_majoration_rc, :integer
    add_column :montant_revisions, :points_servis_rc, :integer
    add_column :montant_revisions, :points_gratuits_rc, :integer

    add_column :montant_revisions, :montant_revision_rg, :float
    add_column :montant_revisions, :points_cotisation_rg, :integer
    add_column :montant_revisions, :points_minoration_rg, :integer
    add_column :montant_revisions, :points_base_rg, :integer
    add_column :montant_revisions, :points_majoration_rg, :integer
    add_column :montant_revisions, :points_servis_rg, :integer
    add_column :montant_revisions, :points_gratuits_rg, :integer
  end
end
