class ChangeTauxUtileTofloat < ActiveRecord::Migration[5.2]
  def change
    change_column :rentiers, :taux_utile, :float
  end
end
