class AddEdiIdToPsrmParticipant < ActiveRecord::Migration[5.2]
  def change
    add_column :psrm_participants, :edi_id, :integer
    add_index :psrm_participants, :edi_id
  end
end
