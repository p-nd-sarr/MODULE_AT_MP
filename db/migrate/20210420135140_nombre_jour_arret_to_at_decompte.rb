class NombreJourArretToAtDecompte < ActiveRecord::Migration[5.2]
  def change
    add_column :arret_travails, :nombre_jour, :integer
  end
end
