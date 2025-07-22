class AddFieldAllocataire < ActiveRecord::Migration[5.2]
  def change
    add_column :allocataires, :email, :string
  end
end
