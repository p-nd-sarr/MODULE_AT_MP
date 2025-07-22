class AddColumnsEstReprisAndNoSinistreToAtRechutes < ActiveRecord::Migration[5.2]
  def change
    add_column :at_rechutes, :est_repris, :boolean, default: false
    add_column :at_rechutes, :no_sinistre, :string
  end
end
