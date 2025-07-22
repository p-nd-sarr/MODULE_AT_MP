class RenameParticipantToPsrmParticipant < ActiveRecord::Migration[5.2]
  def change
    rename_table :participants, :psrm_participants
  end
end
