class AddDateExpirationToDocumentAllocatFamiliale < ActiveRecord::Migration[5.2]
  def change
    add_column :document_allocat_familiales, :date_expiration_piece, :date
  end
end
