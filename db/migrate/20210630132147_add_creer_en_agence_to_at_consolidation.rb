class AddCreerEnAgenceToAtConsolidation < ActiveRecord::Migration[5.2]
  def change
    add_column :at_consolidations, :creer_en_agence, :boolean, default: true
  end
end
