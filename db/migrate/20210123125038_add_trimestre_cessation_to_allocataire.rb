class AddTrimestreCessationToAllocataire < ActiveRecord::Migration[5.2]
  def change
    add_column :allocataires, :trimestre_cessation, :integer
  end
end
