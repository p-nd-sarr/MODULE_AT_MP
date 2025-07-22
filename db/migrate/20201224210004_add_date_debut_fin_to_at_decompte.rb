class AddDateDebutFinToAtDecompte < ActiveRecord::Migration[5.2]
  def change
    add_column :at_decomptes, :date_debut, :date
    add_column :at_decomptes, :date_fin, :date
  end
end
