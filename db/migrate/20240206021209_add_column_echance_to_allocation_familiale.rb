class AddColumnEchanceToAllocationFamiliale < ActiveRecord::Migration[5.2]
  def change
    add_reference :allocation_familiales, :echeance_caisse, foreign_key: true
    add_reference :allocation_familiales, :echeance_caisse_lot_liquidation, foreign_key: true, index: { name: 'echeance_lot_id' }
  end
end
