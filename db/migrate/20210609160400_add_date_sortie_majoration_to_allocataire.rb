class AddDateSortieMajorationToAllocataire < ActiveRecord::Migration[5.2]
  def change
    add_column :allocataires, :date_sortie_majoration, :date
  end
end
