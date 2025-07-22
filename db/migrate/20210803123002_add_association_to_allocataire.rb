class AddAssociationToAllocataire < ActiveRecord::Migration[5.2]
  def change
    add_column :allocataires, :affiliation_association, :string
  end
end
