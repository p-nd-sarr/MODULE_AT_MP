class AddInstruitRevision < ActiveRecord::Migration[5.2]
  def change

    add_column :revision_pensions, :instruit_par_id, :integer
    add_column :revision_pensions, :instruit_le, :datetime

    rename_column :revision_pensions, :afecter_allocataire_le, :affecter_allocataire_date
    rename_column :revision_pensions, :afecter_salarie_le, :affecter_salarie_date
  end
end
