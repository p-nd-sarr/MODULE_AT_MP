class AddColumnDateExpirationPieceSalarieToConjoint < ActiveRecord::Migration[5.2]
  def change
    add_column :conjoints, :date_expiration_piece_salarie, :date
    add_column :conjoints, :date_delivrance_piece_salarie, :date
  end
end
