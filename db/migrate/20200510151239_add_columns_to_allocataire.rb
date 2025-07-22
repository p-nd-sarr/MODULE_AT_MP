class AddColumnsToAllocataire < ActiveRecord::Migration[5.2]
  def change
    add_column :allocataires, :date_soumission, :date
    add_column :allocataires, :date_suspension, :date
  end
end
