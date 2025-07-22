class AddDateExpirationToDocument < ActiveRecord::Migration[5.2]
  def change
    add_column :documents, :date_expiration, :date
  end
end
