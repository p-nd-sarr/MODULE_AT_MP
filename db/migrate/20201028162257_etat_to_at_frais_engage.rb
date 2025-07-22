class EtatToAtFraisEngage < ActiveRecord::Migration[5.2]
  def change
    add_column :at_frais_engages, :etat, :integer
  end
end
