class AddColumnPayableToEcheanceCaisseEnfant < ActiveRecord::Migration[5.2]
  def change
    add_column :echeance_caisse_enfants, :payable, :boolean, default: true
  end
end
