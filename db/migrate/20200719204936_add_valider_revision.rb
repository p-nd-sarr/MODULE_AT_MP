class AddValiderRevision < ActiveRecord::Migration[5.2]
  def change
    add_column :revision_pensions, :valider_par_id, :integer
    add_column :revision_pensions, :valider_le, :datetime

    add_column :revision_pensions, :soumis_par_id, :integer

    add_column :revision_pensions, :commentaire_allocataire, :string
  end
end
