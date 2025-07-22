class AdDateDelivrancePieceToEnfant < ActiveRecord::Migration[5.2]
  def change
    add_column :enfants, :date_delivrance_piece, :date
  end
end
