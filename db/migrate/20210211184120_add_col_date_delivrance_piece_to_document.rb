class AddColDateDelivrancePieceToDocument < ActiveRecord::Migration[5.2]
  def change
    add_column :documents, :date_delivrance_piece, :date
  end
end
