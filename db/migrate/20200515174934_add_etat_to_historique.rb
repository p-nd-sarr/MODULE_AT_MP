class AddEtatToHistorique < ActiveRecord::Migration[5.2]
  def change
    add_column :historiques, :etat, :integer
  end
end
