class AddEstCalculToAtDecomptes < ActiveRecord::Migration[5.2]
  def change
    add_column :at_decomptes, :est_calculer, :boolean, :default => false
  end
end
