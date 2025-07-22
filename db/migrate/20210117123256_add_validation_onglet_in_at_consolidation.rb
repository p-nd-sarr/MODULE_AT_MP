class AddValidationOngletInAtConsolidation < ActiveRecord::Migration[5.2]
  def change
    add_column :at_consolidations, :tableau_rente_valide, :boolean, default: false
    add_column :at_consolidations, :information_salaire_valide, :boolean, default: false
  end
end
