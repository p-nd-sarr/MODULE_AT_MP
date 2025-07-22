class AddColumnSoliciteMedecinToAtDecompte < ActiveRecord::Migration[5.2]
  def change
    add_column :at_decomptes, :solicite_medecin, :boolean, :default => false
  end
end
