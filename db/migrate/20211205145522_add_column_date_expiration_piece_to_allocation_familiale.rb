class AddColumnDateExpirationPieceToAllocationFamiliale < ActiveRecord::Migration[5.2]
  def change
    add_column :allocation_familiales, :date_expiration_piece, :date
  end
end
