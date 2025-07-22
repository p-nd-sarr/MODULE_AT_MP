class AddDateExpirationPieceToenfants < ActiveRecord::Migration[5.2]
  def change
    add_column :enfants, :date_expiration_piece, :date
  end
end
