class AddColumnsEstReprisAndNoSinistreToAtLesions < ActiveRecord::Migration[5.2]
  def change
    add_column :at_lesions, :est_repris, :boolean, default: false
    add_column :at_lesions, :no_sinistre, :string
  end
end
