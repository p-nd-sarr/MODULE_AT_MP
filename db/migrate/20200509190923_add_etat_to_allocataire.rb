class AddEtatToAllocataire < ActiveRecord::Migration[5.2]
  def change
    add_column :allocataires, :etat, :integer
  end
end
