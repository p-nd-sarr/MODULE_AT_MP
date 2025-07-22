class AddTauxAtImmatriculation < ActiveRecord::Migration[5.2]
  def change

    add_column :immatriculation_private_societes, :taux_at, :float
  end
end
