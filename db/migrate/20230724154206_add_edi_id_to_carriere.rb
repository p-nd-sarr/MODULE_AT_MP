class AddEdiIdToCarriere < ActiveRecord::Migration[5.2]
  def change
    add_column :carrieres, :edi_id, :integer
    add_index :carrieres, :edi_id
  end
end
