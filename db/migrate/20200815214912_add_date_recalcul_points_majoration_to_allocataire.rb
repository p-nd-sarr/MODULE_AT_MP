class AddDateRecalculPointsMajorationToAllocataire < ActiveRecord::Migration[5.2]
  def change
    add_column :allocataires, :date_recalcul_points_majoration, :date
  end
end
