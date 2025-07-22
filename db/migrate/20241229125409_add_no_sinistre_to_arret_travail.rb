class AddNoSinistreToArretTravail < ActiveRecord::Migration[5.2]
  def change
    add_column :arret_travails, :no_sinistre, :string
  end
end
