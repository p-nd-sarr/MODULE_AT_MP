class AddLiquideToEcheanceCaisseEnfant < ActiveRecord::Migration[5.2]
  def change
    add_column :echeance_caisse_enfants, :liquide, :boolean, default: false
  end
end
