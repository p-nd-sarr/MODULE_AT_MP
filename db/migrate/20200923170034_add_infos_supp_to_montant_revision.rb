class AddInfosSuppToMontantRevision < ActiveRecord::Migration[5.2]
  def change
    add_column :montant_revisions, :periode_debut, :date, null: false
    add_column :montant_revisions, :periode_fin, :date, null: false

    add_column :montant_revisions, :points_cotisation, :integer
    add_column :montant_revisions, :points_minoration, :integer
    add_column :montant_revisions, :points_base, :integer
    add_column :montant_revisions, :point_majoration, :integer

    add_column :montant_revisions, :montant_revision_total, :float

    remove_column :montant_revisions, :type_regime_id, :integer
    remove_column :montant_revisions, :valeur_point_annuel, :float
  end
end
