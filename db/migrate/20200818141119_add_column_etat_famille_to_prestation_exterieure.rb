class AddColumnEtatFamilleToPrestationExterieure < ActiveRecord::Migration[5.2]
  def change
    add_column :prestation_exterieures, :etat_famille_valid, :boolean, default: false
  end
end
