class AddSuspenduNonPointeToAllocataire < ActiveRecord::Migration[5.2]
  def change
    add_column :allocataires, :suspendu_non_pointe, :boolean
  end
end
