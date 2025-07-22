class AddColumnEtatToPrestationExterieure < ActiveRecord::Migration[5.2]
  def change
    add_column :prestation_exterieures, :etat, :integer
  end
end
