class AddFromPsrmToPsrmParticipant < ActiveRecord::Migration[5.2]
  def change
    add_column :psrm_participants, :from_psrm, :boolean, default: false, null: false
  end
end
