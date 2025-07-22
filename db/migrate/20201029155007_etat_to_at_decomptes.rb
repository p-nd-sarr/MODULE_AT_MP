class EtatToAtDecomptes < ActiveRecord::Migration[5.2]
  def change
    add_column :at_decomptes, :etat, :integer
  end
end
