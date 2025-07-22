class AddUniqConstraintToPaiementNumero < ActiveRecord::Migration[5.2]
  def change
    remove_index :caisse_paiements, :numero_ordre
    add_index :caisse_paiements, :numero_ordre, unique: true
  end
end
