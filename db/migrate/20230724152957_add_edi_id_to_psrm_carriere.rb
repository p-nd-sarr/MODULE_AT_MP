class AddEdiIdToPsrmCarriere < ActiveRecord::Migration[5.2]
  def change
    add_column :psrm_carrieres, :edi_id, :integer
    add_index :psrm_carrieres, :edi_id
  end
end
