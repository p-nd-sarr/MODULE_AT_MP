class AddOldArrondiEnCoursToAllocataire < ActiveRecord::Migration[5.2]
  def change
    add_column :allocataires, :old_arrondi_en_cours, :float, null: false, default: 0
  end
end
