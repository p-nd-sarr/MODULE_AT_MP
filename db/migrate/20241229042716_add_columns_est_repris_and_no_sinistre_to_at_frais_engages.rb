class AddColumnsEstReprisAndNoSinistreToAtFraisEngages < ActiveRecord::Migration[5.2]
  def change
    add_column :at_frais_engages, :est_repris, :boolean, default: false
    add_column :at_frais_engages, :no_sinistre, :string
  end
end
