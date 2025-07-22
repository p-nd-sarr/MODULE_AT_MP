class AddNumeroCarnetToVenteCarnet < ActiveRecord::Migration[5.2]
  def change
    add_column :at_vente_carnets, :numero_carnet, :text, array: true, default: []
  end
end
