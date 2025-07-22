class AddEstCalculerColumnToAtIncapacites < ActiveRecord::Migration[5.2]
  def change
    add_column :at_incapacites, :est_calculer, :boolean, default: :false
  end
end
