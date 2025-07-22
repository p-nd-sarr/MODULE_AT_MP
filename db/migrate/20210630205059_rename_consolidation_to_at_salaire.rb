class RenameConsolidationToAtSalaire < ActiveRecord::Migration[5.2]
  def change
    add_column :at_salaires, :at_rente_famille_id, :integer
    add_column :at_salaires, :arret_travail_id, :integer
  end
end
