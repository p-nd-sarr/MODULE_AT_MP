class AddTauxContractuelToBareme < ActiveRecord::Migration[5.2]
  def change
    add_column :admin_baremes, :taux_contractuel, :float, null: false
  end
end
