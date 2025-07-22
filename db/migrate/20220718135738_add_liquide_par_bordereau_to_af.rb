class AddLiquideParBordereauToAf < ActiveRecord::Migration[5.2]
  def change
    add_column :allocation_familiales, :liquide_par_bordereau_id, :integer
  end
end
