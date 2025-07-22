class RenameAgenceToAgenceIdFromUser < ActiveRecord::Migration[5.2]
  def change
    rename_column :users, :agence, :agence_id
  end
end
