class AddAdresseDomicileToAllocataire < ActiveRecord::Migration[5.2]
  def change
    add_column :allocataires, :adresse_domicile, :string
  end
end
