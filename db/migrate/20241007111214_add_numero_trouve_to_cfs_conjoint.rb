class AddNumeroTrouveToCfsConjoint < ActiveRecord::Migration[5.2]
  def change
    add_column :liquidation_retraite_frances, :numero_trouve, :boolean, :default => false

  end
end
