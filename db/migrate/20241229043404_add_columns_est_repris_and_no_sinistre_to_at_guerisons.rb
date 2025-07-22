class AddColumnsEstReprisAndNoSinistreToAtGuerisons < ActiveRecord::Migration[5.2]
  def change
    add_column :at_guerisons, :est_repris, :boolean, default: false
    add_column :at_guerisons, :no_sinistre, :string
  end
end
