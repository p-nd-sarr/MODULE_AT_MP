class RenameAffiliationAssociationToAllocataire < ActiveRecord::Migration[5.2]
  def change
    add_column :allocataires, :admin_association_allocataire_id, :integer
    remove_column :allocataires, :affiliation_association, :string
  end
end
