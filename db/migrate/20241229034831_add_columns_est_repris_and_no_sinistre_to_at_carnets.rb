class AddColumnsEstReprisAndNoSinistreToAtCarnets < ActiveRecord::Migration[5.2]
  def change
    add_column :at_carnets, :est_repris, :boolean, default: false
    add_column :at_carnets, :no_sinistre, :string
  end
end
