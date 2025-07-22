class AddColumnsEstReprisAndNoSinistreToAtDecomptes < ActiveRecord::Migration[5.2]
  def change
    add_column :at_decomptes, :est_repris, :boolean, default: false
    add_column :at_decomptes, :no_sinistre, :string
  end
end
