class AddAdminAgenceRevision < ActiveRecord::Migration[5.2]
  def change
    add_column :revision_pensions, :admin_agence_id, :integer
  end
end