class AddEcheanceVeuveInfoToAllocationFamiliale < ActiveRecord::Migration[5.2]
  def change
    add_reference :allocation_familiales, :echeance_veuves_caisse, foreign_key: true
    add_reference :allocation_familiales, :echeance_veuves_caisse_lot_liquidation, foreign_key: true, index: { name: 'echeance_veuve_lot_id' }
  end
end
