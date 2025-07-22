class AddRappelDeposeToAllocataire < ActiveRecord::Migration[5.2]
  def change
    add_column :allocataires, :rappel_depose, :boolean, default: false
  end
end
